# frozen_string_literal: true

require "footgauntlet/core/models/team_points"

module Footgauntlet
  module Core
    class Processor
      class LeaguePoints
        module Values
          WIN = 3
          TIE = 1
          LOSS = 0
        end

        def tally(game)
          if game.tied?
            game.teams.each do |team|
              tallies[team].tally(Values::TIE)
            end
          else
            tallies[game.winner].tally(Values::WIN)
            tallies[game.loser].tally(Values::LOSS)
          end
        end

        def max(...)
          tallies.each_value.max(...)
        end

        private

        def tallies
          @tallies ||=
            Hash.new do |memo, team|
              team_points = Models::TeamPoints.new(team: team)
              memo[team] = team_points
            end
        end
      end
    end
  end
end
