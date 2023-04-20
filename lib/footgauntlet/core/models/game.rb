# frozen_string_literal: true

require "set"
require "utils/read_only_struct"

module Footgauntlet
  module Core
    module Models
      class Game < ReadOnlyStruct.new(:home_score, :away_score)
        def teams
          @teams ||= Set[
            home_score.team,
            away_score.team
          ]
        end

        def winner
          compare
          @winner
        end

        def loser
          compare
          @loser
        end

        def tied?
          compare
          @winner.nil?
        end

        private

        def compare
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
end