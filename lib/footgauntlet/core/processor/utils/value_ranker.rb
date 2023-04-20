# frozen_string_literal: true

module Footgauntlet
  module Core
    class Processor
      module Utils
        class ValueRanker
          def rank(value)
            @rank_value ||= value
            @rank ||= 1

            if value < @rank_value
              @rank_value = value
              @rank += 1
            end

            @rank
          end
        end
      end
    end
  end
end
