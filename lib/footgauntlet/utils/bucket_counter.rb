# frozen_string_literal: true

# Maybe this is more appropriately named `UniqueRunCounter`, but that is a
# little onerous. The test examples for this class help demonstrate that this
# class is really concerned with "unique runs".
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
