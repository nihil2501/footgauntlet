# frozen_string_literal: true

require "footgauntlet/core/models/team_points"

module Footgauntlet
  module Core
    class Processor
      class LeaguePoints
        include Enumerable

        module Awards
          WIN = 3
          TIE = 1
          LOSS = 0
        end

        def award(game)
          if game.tied?
            game.teams.each do |team|
              tallies[team].award(Awards::TIE)
            end
          else
            tallies[game.winner].award(Awards::WIN)
            tallies[game.loser].award(Awards::LOSS)
          end
        end

        def each(...)
          tallies.each_value(...)
        end

        private

        def tallies
          @tallies ||=
            Hash.new do |memo, team|
              team_points = Models::TeamPoints.new(team:)
              memo[team] = team_points
            end
        end
      end
    end
  end
end
