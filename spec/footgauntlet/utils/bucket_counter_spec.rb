# frozen_string_literal: true

require "footgauntlet/utils/bucket_counter"
require "spec_helper"

describe BucketCounter do
  before do
    @bucket_counter = BucketCounter.new
  end

  describe "#value" do
    describe "due to a string of #complete? and #complete! commands" do
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

        actual =
          @commands.map do |args|
            command, *args = args
            @bucket_counter.send(command, *args)
            @bucket_counter.value
          end

        assert_equal(
          expected,
          actual
        )
      end
    end
  end
end
