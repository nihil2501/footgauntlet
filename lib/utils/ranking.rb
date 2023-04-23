# frozen_string_literal: true

require "utils/configuration_factory"

# https://en.wikipedia.org/wiki/Ranking#Standard_competition_ranking_(%221224%22_ranking)
module Ranking
  Configuration =
    ConfigurationFactory.create(
      :enumerable,
      :map,
      compare: -> { _1 <=> _2 },
      inner_compare: -> { _1 <=> _2 },
      top_count: nil,
    )

  class << self
    def generate(&)
      config = Configuration.new(&)
      max_args = [config.top_count].compact

      els =
        config.enumerable.max(*max_args) do |a, b|
          memo = config.compare.(a, b)
          memo = config.inner_compare.(a, b) if memo.zero?
          memo
        end

      previous_el = nil
      rank = 1

      els.map! do |el|
        outranked = !previous_el.nil?
        outranked &&= config.compare.(el, previous_el).negative?
        rank += 1 if outranked

        previous_el = el
        config.map.(el, rank)
      end
    end
  end
end
