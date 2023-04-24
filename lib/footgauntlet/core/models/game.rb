# frozen_string_literal: true

require "footgauntlet/utils/read_only_struct"

module Footgauntlet
  module Core
    # This doesn't quite work with Ruby's builtin `Data` because we're doing
    # memoization with instance variables but `Data` objects are frozen.
    class Game < ReadOnlyStruct.new(:home_score, :away_score)
      def teams
        @teams ||= Set[
          home_score.team,
          away_score.team
        ]
      end

      def winner
        determine_outcome
        @winner
      end

      def loser
        determine_outcome
        @loser
      end

      def tied?
        determine_outcome
        @winner.nil?
      end

      private

      def determine_outcome
        return if @comparison
        @comparison =
          home_score.score <=>
            away_score.score

        case @comparison
        when 1
          @winner = home_score.team
          @loser = away_score.team
        when -1
          @winner = away_score.team
          @loser = home_score.team
        end
      end
    end
  end
end