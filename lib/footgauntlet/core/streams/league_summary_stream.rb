# frozen_string_literal: true

require "footgauntlet/core/models"
require "footgauntlet/core/processors/league_summary_processor"
require "footgauntlet/utils/brod/stream"
require "footgauntlet/utils/brod/consumer"

module Footgauntlet
  module Core
    class LeagueSummaryStream 
      class << self
        def build
          Brod::Stream.new(
            Config::Stream,
            Config::Source,
            Config::Sink,
          )
        end
      end

      module Config
        module Stream
          class << self
            def processor
              LeagueSummaryProcessor
            end

            def emit_on_stop
              true
            end
          end
        end

        module Source
          TEAM_REGEX = /^([a-zA-Z\s]+)\s+(\d+)\s*$/

          class << self
            def topic_name
              "games"
            end

            def deserialize(game)
              team_scores =
                game.split(",").map! do |team|
                  match = team.match(TEAM_REGEX)
                  raise Brod::Consumer::DeserializationError, game if match.nil?

                  team_name, score = match.captures
                  team = Team.new(name: team_name.strip)
                  score = score.to_i

                  TeamScore.new(
                    team:,
                    score:,
                  )
                end

              raise Brod::Consumer::DeserializationError, game if team_scores.size != 2
              home_score, away_score = team_scores

              Game.new(
                home_score:,
                away_score:,
              )
            end

            def handle_deserialization_error(error)
              # Warn and move on.
              Footgauntlet.logger.warn(error)
            end
          end
        end

        module Sink
          class << self
            def topic_name
              "league_summaries"
            end

            def serialize(summary)
              String.new.tap do |memo|
                memo << "Matchday #{summary.matchday_number}\n"

                summary.ranking.each do |ranked_team_points|
                  name = ranked_team_points.team.name
                  points = ranked_team_points.points
                  unit = points == 1 ? "pt" : "pts"

                  # Rank is currently unused but nonetheless appears barely
                  # unambiguously enough in the prompt.
                  memo << "#{name}, #{points} #{unit}\n"
                end

                memo << "\n"
              end
            end
          end
        end
      end
    end
  end
end