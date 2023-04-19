# frozen_sting_literal: true

module Footgauntlet
  module MatchdayAggregator
    def initialize(&on_complete)
      @on_complete = on_complete
    end

    def tally_game(game)
    end
  end
end
  