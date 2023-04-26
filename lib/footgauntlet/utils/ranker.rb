# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"

# https://web.archive.org/web/20230421144050/https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
class Ranker
  # Nuances of producing a ranking result in this interface. Firstly, one can
  # consider behavior that is specified once upfront and behavior that is
  # specified for successive productions of rankings. The upfront behavior
  # essentially defines a type of ranking in terms of more static properties.
  #
  # These are:
  # * `comparator` (determines rank)
  # * `inner_comparator` (determines inner-rank ordering)
  # * `map` (produces output when yielded object and rank)
  #
  # It is straightforward that `count` is a more dynamic argument for producing
  # a ranking. `enumerable` is also taken as an argument to `rank` so that there
  # is no assumption that we have a mutable collection that changes between
  # calls to `rank` (e.g. the `Enumerable` interface).
  Definition =
    ConfigurationFactory.create(
      :map,
      comparator: -> { _1 <=> _2 },
      inner_comparator: -> { _1 <=> _2 },
    )

  def initialize(&)
    @definition = Definition.new(&)
  end

  def rank(enumerable, count = nil)
    call, reversal =
      if count
        [[:max, count], 1]
      else
        [[:sort], -1]
      end

    els =
      enumerable.send(*call) do
        memo = @definition.comparator.call(_1, _2)
        memo = @definition.inner_comparator.call(_1, _2) if memo.zero?
        reversal * memo
      end

    previous_el = nil
    rank = 1

    els.map!.with_index do |el, i|
      outranked = !previous_el.nil?
      outranked &&= @definition.comparator.call(el, previous_el).negative?
      rank = i + 1 if outranked

      previous_el = el
      @definition.map.call(el, rank)
    end
  end
end
