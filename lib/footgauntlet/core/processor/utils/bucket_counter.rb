# frozen_string_literal: true

require "set"

module Footgauntlet
  module Core
    class Processor
      module Utils
        class BucketCounter
          attr_reader :value

          def initialize
            @bucket = Set[]
            @value = 0
          end

          def complete?(items)
            # Operand order already optimized with respect to cardinality by
            # implementation of `Set#intersect?`.
            items.intersect?(@bucket).tap do |memo|
              if memo
                @bucket.clear
                @value += 1
              end

              @bucket.merge(
                items
              )
            end
          end
        end
      end
    end
  end
end
