# frozen_string_literal: true

require "utils/configuration_factory"

# https://web.archive.org/web/20230421144050/https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
class Ranking
  Configuration =
    ConfigurationFactory.create(
      :enumerable,
      :map,
      compare: -> { _1 <=> _2 },
      inner_compare: -> { _1 <=> _2 },
      top_count: nil,
    )

  def initialize(&)
    @config = Configuration.new(&)
  end

  def rank
    max_args = [@config.top_count].compact

    els =
      @config.enumerable.max(*max_args) do
        memo = @config.compare.(_1, _2)
        memo = @config.inner_compare.(_1, _2) if memo.zero?
        memo
      end

    previous_el = nil
    rank = 1

    els.map! do |el|
      outranked = !previous_el.nil?
      outranked &&= @config.compare.(el, previous_el).negative?
      rank += 1 if outranked

      previous_el = el
      @config.map.(el, rank)
    end
  end
end
