# frozen_string_literal: true

module Footgauntlet
  module Core
    class LeagueSummaryProcessor
      class UniqueRunTracker
        attr_reader :count

        def initialize
          @unique_run = Set[]
          @count = 0
        end

        def complete?(items)
          # Interesting note: operand order already optimized with respect to
          # cardinality by implementation of `Set#intersect?`:
          #   https://github.com/ruby/ruby/blob/v3_2_2/lib/set.rb#L483
          items.intersect?(@unique_run).tap do |memo|
            complete! if memo
            @unique_run.merge(items)
          end
        end

        def complete!
          @unique_run.clear
          @count += 1
        end
      end
    end
  end
end
