# frozen_string_literal: true

require "footgauntlet/core/models/league_summary"
require "footgauntlet/core/models/ranked_team_points"
require "footgauntlet/core/processor/league_points"
require "utils/bucket_counter"
require "utils/ranker"

module Footgauntlet
  module Core
    # TODO: Move this to a named processer (something about 'league summary') as
    # part of an idea to have this app be a stream processor for multiple
    # streams a la Apache Kafka. After named, internal names can drop redundant
    # prefixes.
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
        COUNT = 3
      end

      def emit_league_summary
        @league_ranker ||=
          Ranker.new do |definition|
            definition.compare = LeagueRanking::COMPARE
            definition.inner_compare = LeagueRanking::INNER_COMPARE

            definition.map =
              lambda do |team_points, rank|
                Models::RankedTeamPoints.new(
                  team_points:,
                  rank:,
                )
              end
          end

        league_ranking =
          @league_ranker.rank(
            @league_points,
            LeagueRanking::COUNT,
          )

        league_summary =
          Models::LeagueSummary.new(
            matchday_number: @matchday_counter.value,
            ranking: league_ranking,
          )

        @emit_callback.(league_summary)
      end
    end
  end
end
