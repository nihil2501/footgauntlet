# frozen_string_literal: true

require "footgauntlet/utils/ranker"
require "test_helper"

describe Ranker do
  describe ".new" do
    describe "without a `map` configured" do
      it "raises a `MissingRequiredAttributesError`" do
        _ { Ranker.new { } }.must_raise(
          Ranker::Definition::MissingRequiredAttributesError
        )
      end
    end
  end

  describe "#rank" do
    before do
      @enumerable = 1..9
    end

    describe "with comparators specified" do
      before do
        @ranker =
          Ranker.new do |definition|
            definition.comparator = -> { _1 / 3 <=> _2 / 3 }
            definition.inner_comparator = -> { _2 <=> _1 }
            definition.map = -> (object, rank) { [rank, object] }
          end
      end

      describe "with `count` argument provided" do
        before do
          @args = [4]
        end

        it "gives back the top `count` ranked" do
          expected = [
            [1, 9],
            [2, 6], [2, 7], [2, 8],
          ]

          actual = @ranker.rank(@enumerable, *@args)

          assert_equal(
            expected,
            actual
          )
        end
      end

      describe "without `count` argument provided" do
        before do
          @args = []
        end

        it "gives back all ranked" do
          expected = [
            [1, 9],
            [2, 6], [2, 7], [2, 8],
            [5, 3], [5, 4], [5, 5],
            [8, 1], [8, 2],
          ]

          actual = @ranker.rank(@enumerable, *@args)

          assert_equal(
            expected,
            actual
          )
        end
      end
    end

    describe "with comparators unspecified" do
      before do
        @ranker =
          Ranker.new do |definition|
            definition.map = -> (object, rank) { [rank, object] }
          end
      end

      it "uses trivial comparator" do
        expected = [
          [1, 9],
          [2, 8],
          [3, 7],
          [4, 6],
          [5, 5],
          [6, 4],
          [7, 3],
          [8, 2],
          [9, 1],
        ]

        actual = @ranker.rank(@enumerable, *@args)

        assert_equal(
          expected,
          actual
        )
      end
    end
  end
end
