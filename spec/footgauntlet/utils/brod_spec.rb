# frozen_string_literal: true

require "footgauntlet/utils/brod/stream"
require "spec_helper"

describe Brod do
  class Processor
    def initialize(&on_emit)
      @on_emit = on_emit
    end

    def ingest(record)
      @on_emit.call(record ** 2)
    end
  end

  before do
    @source = 1..5
    @sink = []

    @producer = BrodHelpers::Producer.build("source")

    consumer =
      BrodHelpers::Consumer.build("sink") do |record|
        @sink << record
      end

    @producer.start
    consumer.start

    BrodHelpers::Stream.build(Processor, "source", "top").start
    BrodHelpers::Stream.build(Processor, "source", "bottom").start
    BrodHelpers::Stream.build(Processor, "top", "sink").start
    BrodHelpers::Stream.build(Processor, "bottom", "sink").start
  end

  it "affords a diamond topoloy" do
    @source.each do |record|
      @producer.produce(record)
    end

    # Doubles of each number raised to the 4th power.
    expected = [1, 1, 16, 16, 81, 81, 256, 256, 625, 625].sort!
    actual = @sink.sort!

    assert_equal(
      expected,
      actual
    )
  end
end
