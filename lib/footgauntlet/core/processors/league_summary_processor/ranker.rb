# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"

module Footgauntlet
  module Core
    # This class is totally generic and makes no reference to anything in the
    # domain logic of a league summary. But it lives here anyway because it
    # doesn't seem like a generally useful utility.
    class LeagueSummaryProcessor
      # https://web.archive.org/web/20230421144050/https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
      class Ranker
        # Nuances of producing a ranking result in this interface. Firstly, one
        # can consider behavior that is specified once upfront and behavior that
        # is specified for successive productions of rankings. The upfront
        # behavior essentially defines a type of ranking in terms of more static
        # properties.
        #
        # These are:
        # * `comparator` (determines rank)
        # * `inner_comparator` (determines inner-rank ordering)
        # * `map` (produces output when yielded object and rank)
        #
        # It is straightforward that `count` is a more dynamic argument for
        # producing a ranking. `items` is also taken as an argument to `rank` so
        # that there is no assumption that we have a mutable collection that
        # changes between calls to `rank` (e.g. the `Enumerable` interface).
        Definition =
          ConfigurationFactory.create(
            :map,
            comparator: -> { _1 <=> _2 },
            inner_comparator: -> { _1 <=> _2 },
          )

        def initialize(&)
          @definition = Definition.new(&)
        end

        def rank(items, count = nil)
          call, reversal =
            if count
              [[:max, count], 1]
            else
              # `-1` because `sort` is ascending while `max` is descending.
              [[:sort], -1]
            end

          items =
            items.send(*call) do
              memo = @definition.comparator.call(_1, _2)
              memo = @definition.inner_comparator.call(_1, _2) if memo.zero?
              reversal * memo
            end

          previous_item = nil
          rank = 1

          items.map!.with_index do |item, i|
            outranked = !previous_item.nil?
            outranked &&= @definition.comparator.call(item, previous_item).negative?
            rank = i + 1 if outranked

            previous_item = item
            @definition.map.call(item, rank)
          end
        end
      end
    end
  end
end
