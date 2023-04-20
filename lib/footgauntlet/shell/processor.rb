# frozen_string_literal: true

require "footgauntlet/error"
require "footgauntlet/core/models"
require "footgauntlet/core/processor"

module Footgauntlet
  module Shell
    module Processor
      DeserializationError = Class.new(Error)      

      TEAM_REGEX = /^([a-zA-Z\s]+)\s+(\d+)\s*$/

      class << self
        def start(options)
          processor =
            Core::Processor.new do |matchday|
              matchday = serialize_matchday(matchday)
              options.output_stream.puts(matchday)
            end

          options.input_stream.each do |game|
            game = deserialize_game(game)
            processor.process(game)
          rescue DeserializationError => ex
            # TODO: Just `warn` this `game` and continue.
          end
        end

        private

        def serialize_matchday(matchday)
          String.new.tap do |memo|
            memo << "Matchday #{matchday.index}\n"

            matchday.top_team_points.each do |team_points|
              name = team_points.team.name
              points = team_points.points
              unit = points == 1 ? "pt" : "pts"

              memo << "#{name}, #{points} #{unit}\n"
            end
          end
        end

        def deserialize_game(game)
          team_scores =
            game.split(",").map! do |team|
              match = team.match(TEAM_REGEX)
              raise DeserializationError if match.nil?

              name, score = match.captures
              team = Core::Models::Team.new(name: name.strip)
              score = score.to_i

              Core::Models::TeamScore.new(
                team: team,
                score: score
              )
            end

          raise DeserializationError if team_scores.size != 2
          home_score, away_score = team_scores

          Core::Models::Game.new(
            home_score: home_score,
            away_score: away_score
          )
        end
      end
    end
  end
end
