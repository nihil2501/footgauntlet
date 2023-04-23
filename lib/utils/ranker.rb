# frozen_string_literal: true

require "utils/configuration_factory"

# https://web.archive.org/web/20230421144050/https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
# TODO: Motivate API. Particularly initialization vs. `rank` method which
# implies that the kind of `Ranker` is static, but rather than assume there is
# also a static mutating collection for which we `rank` multiple times, a new
# collection is given for each `rank` (yet callers can pass same one multiple
# times). Should this distinction apply to other parameters as well (like
# `top_count`)? 
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
    els =
      enumerable.max(*[count].compact) do
        memo = @definition.compare.(_1, _2)
        memo = @definition.inner_compare.(_1, _2) if memo.zero?
        memo
      end

    previous_el = nil
    rank = 1

    els.map! do |el|
      outranked = !previous_el.nil?
      outranked &&= @definition.compare.(el, previous_el).negative?
      rank += 1 if outranked

      previous_el = el
      @definition.map.(el, rank)
    end
  end
end
