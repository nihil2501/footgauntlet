# frozen_string_literal: true

require "footgauntlet/utils/ranker"
require "spec_helper"

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
    Rankable =
      Data.define(:id, :points, :tiebreaker) do
        def <=>(other)
          self.points <=> other.points
        end
      end

    before do
      @enumerable = [
        @rankable_a = Rankable.new(id: :a, points: 1, tiebreaker: 1),
        @rankable_b = Rankable.new(id: :b, points: 2, tiebreaker: 1),
        @rankable_c = Rankable.new(id: :c, points: 3, tiebreaker: 1),
        @rankable_d = Rankable.new(id: :d, points: 1, tiebreaker: 2),
        @rankable_e = Rankable.new(id: :e, points: 2, tiebreaker: 2),
        @rankable_f = Rankable.new(id: :f, points: 3, tiebreaker: 2),
        @rankable_g = Rankable.new(id: :g, points: 1, tiebreaker: 3),
        @rankable_h = Rankable.new(id: :h, points: 2, tiebreaker: 3),
        @rankable_i = Rankable.new(id: :i, points: 3, tiebreaker: 3),
      ]

      @ranker =
        Ranker.new do |definition|
          definition.inner_compare = -> { _2.tiebreaker <=> _1.tiebreaker }
          definition.map = -> (rankable, rank) { [rankable, rank] }
        end
    end

    describe "with `count` argument provided" do
      before do
        @args = [4]
      end

      it "gives back the top `count` ranked" do
        expected = [
          [@rankable_c, 1],
          [@rankable_f, 1],
          [@rankable_i, 1],
          [@rankable_b, 4],
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
          [@rankable_c, 1],
          [@rankable_f, 1],
          [@rankable_i, 1],
          [@rankable_b, 4],
          [@rankable_e, 4],
          [@rankable_h, 4],
          [@rankable_a, 7],
          [@rankable_d, 7],
          [@rankable_g, 7],
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
