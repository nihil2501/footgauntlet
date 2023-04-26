# frozen_string_literal: true

require "footgauntlet/utils/read_only_struct"

module Footgauntlet
  module Core
    # This receives its `hash` function from `Data`. It is a pure
    # calculation of its `members`' `hash` functions, which is exactly what
    # we want.
    Team = Data.define(:name)

    TeamScore =
      Data.define(
        :team,
        :score
      )

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

    class TeamPoints
      attr_reader :team, :points

      def initialize(team:)
        @team = team
        @points = 0
      end

      def award(value)
        @points += value
      end

      def ==(other)
        other.is_a?(TeamPoints) &&
          self.team == other.team &&
          self.points == other.points
      end
    end

    class RankedTeamPoints
      attr_reader :team, :points, :rank

      def initialize(team_points:, rank:)
        @team = team_points.team
        @points = team_points.points
        @rank = rank
      end

      def ==(other)
        other.is_a?(RankedTeamPoints) &&
          self.team == other.team &&
          self.points == other.points &&
          self.rank == other.rank
      end
    end

    LeagueSummary =
      Data.define(
        :matchday_number,
        :ranking,
      )
  end
end
