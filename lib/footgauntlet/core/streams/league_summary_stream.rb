# frozen_string_literal: true

require "footgauntlet/core/models/game"
require "footgauntlet/core/models/team"
require "footgauntlet/core/models/team_score"
require "footgauntlet/core/processors/league_summary_processor"
require "footgauntlet/utils/stream"

module Footgauntlet
  module Core
    LeagueSummaryStream =
      Stream.new do |config|
        config.processor = LeagueSummaryProcessor
        config.source_topic = "games"
        config.sink_topic = "league_summaries"
        config.emit_on_stop = true

        team_regex = /^([a-zA-Z\s]+)\s+(\d+)\s*$/
        config.source_deserializer =
          lambda do |game|
            team_scores =
              game.split(",").map! do |team|
                match = team.match(team_regex)
                raise Stream::DeserializationError if match.nil?

                team_name, score = match.captures
                team = Team.new(name: team_name.strip)
                score = score.to_i

                TeamScore.new(
                  team:,
                  score:,
                )
              end

            raise Stream::DeserializationError if team_scores.size != 2
            home_score, away_score = team_scores

            Game.new(
              home_score:,
              away_score:,
            )
          end

        config.sink_serializer =
          lambda do |summary|
            String.new.tap do |memo|
              memo << "Matchday #{summary.matchday_number}\n"

              summary.ranking.each do |ranked_team_points|
                name = ranked_team_points.team.name
                points = ranked_team_points.points
                unit = points == 1 ? "pt" : "pts"

                # Rank is currently unused but nonetheless appears barely
                # unambiguously enough in the spec.
                memo << "#{name}, #{points} #{unit}\n"
              end

              memo << "\n"
            end
          end
      end
  end
end