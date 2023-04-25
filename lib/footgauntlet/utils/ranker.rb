# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"

# https://web.archive.org/web/20230421144050/https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
class Ranker
  Definition =
    ConfigurationFactory.create(
      :map,
      compare: -> { _1 <=> _2 },
      inner_compare: -> { _1 <=> _2 },
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
        memo = @definition.compare.call(_1, _2)
        memo = @definition.inner_compare.call(_1, _2) if memo.zero?
        reversal * memo
      end

    previous_el = nil
    rank = 1

    els.map!.with_index do |el, i|
      outranked = !previous_el.nil?
      outranked &&= @definition.compare.call(el, previous_el).negative?
      rank = i + 1 if outranked

      previous_el = el
      @definition.map.call(el, rank)
    end
  end
end
