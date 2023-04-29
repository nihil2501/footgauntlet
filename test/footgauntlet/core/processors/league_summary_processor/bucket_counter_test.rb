# frozen_string_literal: true

require "footgauntlet/core/processors/league_summary_processor/unique_run_counter"
require "test_helper"

describe Footgauntlet::Core::LeagueSummaryProcessor::UniqueRunCounter do
  before do
    @counter = Footgauntlet::Core::LeagueSummaryProcessor::UniqueRunCounter.new
    @values = []
  end

  def issue_commands
    @commands.each do |args|
      command, *args = args
      @counter.send(command, *args)
      @values << @counter.value
    end
  end

  describe "due to a stream of #complete? and #complete! commands" do
    before do
      @commands = [
        [:complete!], [:complete?, Set[0]],
        [:complete?, Set[0]], [:complete?, Set[1]],
        [:complete?, Set[0]],
        [:complete!],
        [:complete!], [:complete?, Set[1]], [:complete?, Set[0]],
        [:complete?, Set[1]],
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
      actual = @values

      assert_equal(
        expected,
        actual
      )
    end
  end
end
