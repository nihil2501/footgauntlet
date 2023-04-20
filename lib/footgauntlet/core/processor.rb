# frozen_string_literal: true

require "footgauntlet/core/models/daily_league_summary"
require "footgauntlet/core/models/ranked_team_points"
require "footgauntlet/core/processor/league_points"
require "footgauntlet/core/processor/utils/bucket_counter"
require "footgauntlet/core/processor/utils/value_ranker"

module Footgauntlet
  module Core
    class Processor
      module TopTeamPoints
        COUNT = 3
        COMPARE = -> (a, b) {
          memo = a.points <=> b.points
          memo = b.team.name <=> a.team.name if memo.zero?
          memo
        }
      end

      def initialize(&emit_callback)
        @emit_callback = emit_callback
        @league_points = LeaguePoints.new
        @day_counter = Utils::BucketCounter.new
      end

      def ingest(game)
        if @day_counter.complete?(game.teams)
          summary = calculate_summary
          @emit_callback.(summary)
        end

        @league_points.tally(game)
      end

      private

      def calculate_summary
        top_ranked_team_points =
          # First iteration.
          @league_points.max(
            TopTeamPoints::COUNT,
            &TopTeamPoints::COMPARE
          )        

        enum = top_ranked_team_points.map!
        enum = enum.with_object(Utils::ValueRanker.new)

        # Second, small iteration.
        enum.each do |team_points, points_ranker|
          points = team_points.points
          rank = points_ranker.rank(points)

          Models::RankedTeamPoints.new(
            team_points: team_points,
            rank: rank
          )
        end

        Models::DailyLeagueSummary.new(
          top_ranked_team_points: top_ranked_team_points,
          day_number: @day_counter.value
        )
      end
    end
  end
end
