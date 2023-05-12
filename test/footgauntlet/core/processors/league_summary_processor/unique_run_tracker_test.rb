# frozen_string_literal: true

require "footgauntlet/core/processors/league_summary_processor/unique_run_tracker"
require "test_helper"

describe Footgauntlet::Core::LeagueSummaryProcessor::UniqueRunTracker do
  before do
    @tracker = Footgauntlet::Core::LeagueSummaryProcessor::UniqueRunTracker.new
    @counts = []
  end

  def issue_commands
    @commands.each do |args|
      command, *args = args
      @tracker.send(command, *args)
      @counts << @tracker.count
    end
  end

  describe "due to a stream of #completed_by? and #complete! commands" do
    before do
      @commands = [
        [:complete!], [:completed_by?, Set[0]],
        [:completed_by?, Set[0]], [:completed_by?, Set[1]],
        [:completed_by?, Set[0]],
        [:complete!],
        [:complete!], [:completed_by?, Set[1]], [:completed_by?, Set[0]],
        [:completed_by?, Set[1]],
      ]
    end

    it "counts unique runs with manual punctuation" do
      expected = [
        1, 1,
        2, 2,
        3,
        4,
        5, 5, 5,
        6,
      ]

      issue_commands
      actual = @counts

      assert_equal(
        expected,
        actual
      )
    end
  end
end
