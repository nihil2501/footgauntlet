# frozen_string_literal: true

require "footgauntlet/core/models/league_summary"
require "footgauntlet/core/models/ranked_team_points"
require "footgauntlet/utils/bucket_counter"
require "footgauntlet/utils/ranker"

module Footgauntlet
  module Core
    class LeagueSummaryProcessor
      def initialize(&on_emit)
        @on_emit = on_emit
        @league_points = LeaguePoints.new
        @matchday_counter = BucketCounter.new
      end

      def ingest(game)
        emit_summary if @matchday_counter.complete?(game.teams)
        @league_points.award(game)
      end

      def emit
        @matchday_counter.complete!
        emit_summary
      end

      private

      module Ranking
        COMPARE = -> { _1.points <=> _2.points }
        INNER_COMPARE = -> { _2.team.name <=> _1.team.name }
        COUNT = 3
      end

      def emit_summary
        @ranker ||=
          Ranker.new do |definition|
            definition.compare = Ranking::COMPARE
            definition.inner_compare = Ranking::INNER_COMPARE

            definition.map =
              lambda do |team_points, rank|
                RankedTeamPoints.new(
                  team_points:,
                  rank:,
                )
              end
          end

        matchday_number = @matchday_counter.value
        ranking = @ranker.rank(@league_points, Ranking::COUNT)
        summary = LeagueSummary.new(matchday_number:, ranking:)

        @on_emit.(summary)
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
