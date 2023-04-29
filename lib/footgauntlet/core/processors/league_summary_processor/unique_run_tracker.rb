# frozen_string_literal: true

module Footgauntlet
  module Core
    class LeagueSummaryProcessor
      ##
      # This class tracks unique runs.
      class UniqueRunTracker
        ##
        # Returns the current count of unique runs.
        # @return [Integer] the unique run count
        attr_reader :count

        ##
        # Initializes a new `UniqueRunTracker`
        def initialize
          @unique_run = Set[]
          @count = 0
        end

        ##
        # Checks if the given set of items completes a unique run.
        #
        # @param items [Set] the set of items to check
        # @return [Boolean] true if the unique run is complete, false otherwise
        def complete?(items)
          # Interesting note: operand order already optimized with respect to
          # cardinality by implementation of `Set#intersect?`:
          #   https://github.com/ruby/ruby/blob/v3_2_2/lib/set.rb#L483
          items.intersect?(@unique_run).tap do |memo|
            complete! if memo
            @unique_run.merge(items)
          end
        end

        ##
        # Completes the current unique run, incrementing the `count`.
        def complete!
          @unique_run.clear
          @count += 1
        end
      end
    end
  end
end
