# frozen_string_literal: true

require "footgauntlet/core/models/league_summary"
require "footgauntlet/core/models/ranked_team_points"
require "footgauntlet/core/processor/league_points"
require "utils/bucket_counter"
require "utils/ranking"

module Footgauntlet
  module Core
    class Processor
      module LeagueRanking
        COMPARE = -> { _1.points <=> _2.points }
        INNER_COMPARE = -> { _2.team.name <=> _1.team.name }
        TOP_COUNT = 3
      end

      def initialize(&emit_callback)
        @emit_callback = emit_callback
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

      def emit_summary
        top_ranked_team_points =
          # TODO: Maybe reuse a single ranking object each time we emit.
          Ranking.generate do |config|
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

        summary =
          Models::LeagueSummary.new(
            matchday_count: @matchday_counter.value,
            top_ranked_team_points:,
          )

        @emit_callback.(summary)
      end
    end
  end
end
