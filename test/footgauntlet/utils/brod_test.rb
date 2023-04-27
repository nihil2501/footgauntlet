# frozen_string_literal: true

require "footgauntlet/utils/brod/stream"
require "test_helper"

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
    # TODO: It'd be nice for this to happen automatically otherwise we have a
    # footgun in our footgauntlet.
    Brod::Topic.clear

    @source = 1..5
    @sink = []

    @producer = BrodHelpers::Producer.build("source")
    consumer = BrodHelpers::Consumer.build("sink") do |record|
      @sink << record
    end

    BrodHelpers::Stream.build(Processor, "source", "top").start
    BrodHelpers::Stream.build(Processor, "source", "bottom").start
    BrodHelpers::Stream.build(Processor, "top", "sink").start
    BrodHelpers::Stream.build(Processor, "bottom", "sink").start

    consumer.start
    @producer.start
  end

  #
  #
  #                      ,--Stream-->[top]--Stream-----,
  #                      |                             |
  # Producer-->[source]--|                             |-->[sink]-->Consumer
  #                      |                             |
  #                      '--Stream-->[bottom]--Stream--'
  #
  #
  it "affords a diamond topoloy" do
    produce_source

    # Doubles of each number raised to the 4th power.
    expected = [1, 1, 16, 16, 81, 81, 256, 256, 625, 625].sort!
    actual = @sink.sort!

    assert_equal(
      expected,
      actual
    )
  end

  def produce_source
    @source.each do |record|
      @producer.produce(record)
    end
  end
end
