# frozen_string_literal: true

require "footgauntlet/core/models/game"
require "footgauntlet/core/models/team"
require "footgauntlet/core/models/team_score"
require "footgauntlet/core/processors/league_summary_processor"
require "footgauntlet/utils/brod/stream"
require "footgauntlet/utils/brod/consumer"

module Footgauntlet
  module Core
    LeagueSummaryStream =
      Brod::Stream.new do |config|
        config.processor = LeagueSummaryProcessor
        config.emit_on_stop = true

        config.source_topic_name = "games"
        config.sink_topic_name = "league_summaries"

        team_regex = /^([a-zA-Z\s]+)\s+(\d+)\s*$/
        config.source_deserializer =
          lambda do |game|
            team_scores =
              game.split(",").map! do |team|
                match = team.match(team_regex)
                raise Brod::Consumer::DeserializationError if match.nil?

                team_name, score = match.captures
                team = Team.new(name: team_name.strip)
                score = score.to_i

                TeamScore.new(
                  team:,
                  score:,
                )
              end

            raise Brod::Consumer::DeserializationError if team_scores.size != 2
            home_score, away_score = team_scores

            Game.new(
              home_score:,
              away_score:,
            )
          end

        config.on_source_deserialization_error =
          lambda do |error|
            Footgauntlet.logger.warn(error)
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