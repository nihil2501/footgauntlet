# frozen_string_literal: true

module Footgauntlet
  module Core
    class Processor
      def initialize(&on_complete)
        @on_complete = on_complete
        @league_points = Hash.mew { |h, k| h[k] = 0 }
      end

      def process(game)
        check_day_completion(game)
        # TODO: Accrue some `league_points`.
      end

      private

      # TODO: Inline this?
      def check_day_completion(game)
        @day_teams ||= Set[]
        if game.teams.intersect?(@day_teams)
          # TODO: Build `Matchday` and invoke `on_complete` with it.
          @day_teams.clear
        end

        @day_teams.merge(
          game.teams
        )
      end
    end
  end
end