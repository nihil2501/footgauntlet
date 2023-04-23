# frozen_string_literal: true

require "footgauntlet/core/models/game"
require "footgauntlet/core/models/team"
require "footgauntlet/core/models/team_score"
require "footgauntlet/shell/serialization/deserialization_error"

module Footgauntlet
  module Shell
    module Serialization
      module GameDeserializer
        TEAM_REGEX = /^([a-zA-Z\s]+)\s+(\d+)\s*$/

        class << self
          def perform(game)
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
end
