# frozen_string_literal: true

require "footgauntlet/core/models/league_summary"
require "footgauntlet/core/models/ranked_team_points"
require "footgauntlet/core/processor/league_points"
require "utils/bucket_counter"
require "utils/ranking"

module Footgauntlet
  module Core
    class Processor
      def initialize(&emit_callback)
        @emit_callback = emit_callback
        @league_points = LeaguePoints.new
        @matchday_counter = BucketCounter.new
      end

      def ingest(game)
        emit_league_summary if @matchday_counter.complete?(game.teams)
        @league_points.award(game)
      end

      def emit
        @matchday_counter.complete!
        emit_league_summary
      end

      private

      module LeagueRanking
        COMPARE = -> { _1.points <=> _2.points }
        INNER_COMPARE = -> { _2.team.name <=> _1.team.name }
        TOP_COUNT = 3
      end

      def emit_league_summary
        @league_ranking ||=
          Ranking.new do |config|
            config.compare = LeagueRanking::COMPARE
            config.inner_compare = LeagueRanking::INNER_COMPARE
            config.top_count = LeagueRanking::TOP_COUNT
            config.enumerable = @league_points

            config.map =
              lambda do |team_points, rank|
                Models::RankedTeamPoints.new(
                  team_points:,
                  rank:,
                )
              end
          end

        league_summary =
          Models::LeagueSummary.new(
            top_ranked_team_points: @league_ranking.rank,
            matchday_count: @matchday_counter.value,
          )

        @emit_callback.(league_summary)
      end
    end
  end
end
