# frozen_string_literal: true

class BucketCounter
  attr_reader :value

  def initialize
    @bucket = Set[]
    @value = 0
  end

  def complete?(items)
    # Interesting note: operand order already optimized with respect to
    # cardinality by implementation of `Set#intersect?`.
    items.intersect?(@bucket).tap do |memo|
      complete! if memo
      @bucket.merge(items)
    end
  end

  def complete!
    @bucket.clear
    @value += 1
  end
end
