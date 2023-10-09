# frozen_string_literal: true

require "footgauntlet/core/models"
require "footgauntlet/core/processors/league_summary_processor"
require "test_helper"

describe Footgauntlet::Core::LeagueSummaryProcessor do
  before do
    @summaries = []
    @processor =
      Footgauntlet::Core::LeagueSummaryProcessor.new do |summary|
        @summaries << summary
      end
  end

  def issue_commands
    @commands.each do |args|
      @processor.send(*args)
    end
  end

  describe "#emit domain semantics" do
    before do
      game =
        Footgauntlet::Core::Game.new(
          home_score: Footgauntlet::Core::TeamScore.new(
            team: Footgauntlet::Core::Team.new(name: "Home"),
            score: 0,
          ),
          away_score: Footgauntlet::Core::TeamScore.new(
            team: Footgauntlet::Core::Team.new(name: "Away"),
            score: 0,
          ),
        )

      # There is a requirement, that in the face of quirks in the enclosing
      # process that invokes this model, that it forces this model to yield a
      # particular interpretation of the domain. This requirement is
      # irreconcilable with being meaningful in the domain. The thing to
      # observe in this test example is that the below result is technically a
      # meaningful one, but it also demonstrates that if the enclosing process
      # feeds in the empty feed, that an empty matchday 1 result would actually
      # not be meaningful. In that case, it would make more sense to not emit.
      # It is possible to encode that in the processor but then it wouldn't
      # make sense for this test example.
      @commands = [
        [:emit],
        [:ingest, game],
        [:ingest, game],
      ]
    end

    it "cannot semantically distinguish the empty feed" do
      expected = [
        Footgauntlet::Core::LeagueSummary.new(
          matchday_number: 1,
          ranking: [],
        ),
        Footgauntlet::Core::LeagueSummary.new(
          matchday_number: 2,
          ranking: [
            Footgauntlet::Core::RankedTeamPoints.new(
              rank: 1,
              team_points: award(1, Footgauntlet::Core::TeamPoints.new(
                team: Footgauntlet::Core::Team.new(
                  name: "Away"
                ),
              )),
            ),
            Footgauntlet::Core::RankedTeamPoints.new(
              rank: 1,
              team_points: award(1, Footgauntlet::Core::TeamPoints.new(
                team: Footgauntlet::Core::Team.new(
                  name: "Home"
                ),
              )),
            ),
          ],
        ),
      ]

      issue_commands
      actual = @summaries

      assert_equal(
        expected,
        actual
      )
    end

    def award(points, team_points)
      team_points.award(points)
      team_points
    end
  end
end
