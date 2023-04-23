# frozen_string_literal: true

require "footgauntlet/core/models/game"
require "footgauntlet/core/models/team"
require "footgauntlet/core/models/team_score"
require "footgauntlet/core/processor"
require "footgauntlet/error"

module Footgauntlet
  module Shell
    module Processor
      DeserializationError = Class.new(Error)      

      TEAM_REGEX = /^([a-zA-Z\s]+)\s+(\d+)\s*$/

      class << self
        def start(options)
          processor =
            Core::Processor.new do |summary|
              output = serialize_summary(summary)
              options.output_stream.puts(output)
            end

          options.input_stream.each do |input|
            game = deserialize_game(input)
            processor.ingest(game)
          rescue DeserializationError => ex
            # TODO: Just `warn` this `game` and continue.
          end

          processor.emit
        end

        private

        def serialize_summary(summary)
          String.new.tap do |memo|
            memo << "Matchday #{summary.matchday_number}\n"

            summary.top_ranked_team_points.each do |team_points|
              name = team_points.team.name
              points = team_points.points
              unit = points == 1 ? "pt" : "pts"

              # Rank is currently unused but nonetheless appears barely
              # unambiguously enough in the spec.
              memo << "#{name}, #{points} #{unit}\n"
            end

            memo << "\n"
          end
        end

        def deserialize_game(game)
          team_scores =
            game.split(",").map! do |team|
              match = team.match(TEAM_REGEX)
              raise DeserializationError if match.nil?

              team_name, score = match.captures
              team = Core::Models::Team.new(name: team_name.strip)
              score = score.to_i

              Core::Models::TeamScore.new(
                team:,
                score:,
              )
            end

          raise DeserializationError if team_scores.size != 2
          home_score, away_score = team_scores

          Core::Models::Game.new(
            home_score:,
            away_score:,
          )
        end
      end
    end
  end
end
