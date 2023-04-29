# frozen_string_literal: true

require "footgauntlet/core/models"
require "footgauntlet/core/processors/league_summary_processor/unique_run_tracker"
require "footgauntlet/core/processors/league_summary_processor/ranker"

module Footgauntlet
  module Core
    class LeagueSummaryProcessor
      def initialize(&on_emit)
        @on_emit = on_emit
        @league_points = LeaguePoints.new
        @matchday_tracker = UniqueRunTracker.new
      end

      def ingest(game)
        emit_summary if @matchday_tracker.complete?(game.teams)
        @league_points.award(game)
      end

      def emit
        # What if `emit` is invoked when no games ingested because the enclosing
        # process feeds in the empty feed? The ambiguous semantics of this are
        # discussed in the test suite for this class.
        #
        # The alternative is to prepend in this method body the statement:
        #   `return if @league_points.empty?`
        #
        # Provided that `LeaguePoints` is extended with:
        #   ```
        #   def empty?
        #     tallies.empty?
        #   end
        #   ```
        @matchday_tracker.complete!
        emit_summary
      end

      private

      module Ranking
        COMPARATOR = -> { _1.points <=> _2.points }
        INNER_COMPARATOR = -> { _2.team.name <=> _1.team.name }
        COUNT = 3
      end

      def emit_summary
        @ranker ||=
          Ranker.new do |definition|
            definition.comparator = Ranking::COMPARATOR
            definition.inner_comparator = Ranking::INNER_COMPARATOR

            definition.map =
              lambda do |team_points, rank|
                RankedTeamPoints.new(
                  team_points:,
                  rank:,
                )
              end
          end

        matchday_number = @matchday_tracker.count
        ranking = @ranker.rank(@league_points, Ranking::COUNT)
        summary = LeagueSummary.new(matchday_number:, ranking:)

        @on_emit.call(summary)
      end

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
              team_points = TeamPoints.new(team:)
              memo[team] = team_points
            end
        end
      end
    end
  end
end
