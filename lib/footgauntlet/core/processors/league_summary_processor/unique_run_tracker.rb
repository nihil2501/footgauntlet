# frozen_string_literal: true

module Footgauntlet
  module Core
    # This class is totally generic and makes no reference to anything in the
    # domain logic of a league summary. But it lives here anyway because it
    # doesn't seem like a generally useful utility.
    class LeagueSummaryProcessor
      class UniqueRunTracker
        attr_reader :count

        def initialize
          @unique_run = Set[]
          @count = 0
        end

        def completed_by?(items)
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
