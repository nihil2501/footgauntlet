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
    @source = [1,2,3,4,5]
    @sink = []

    consumer =
      Brod::Consumer.new(consumer_config("sink")) do |record|
        @sink << record
      end

    @producer = Brod::Producer.new(producer_config("source"))
    @producer.start
    consumer.start

    stream_config =
      Object.new.tap do |config|
        class << config
          def processor = Processor
          def emit_on_stop = false
        end
      end

    Brod::Stream.new(
      stream_config,
      consumer_config("source"),
      producer_config("top"),
    ).start

    Brod::Stream.new(
      stream_config,
      consumer_config("source"),
      producer_config("bottom"),
    ).start

    Brod::Stream.new(
      stream_config,
      consumer_config("top"),
      producer_config("sink"),
    ).start

    Brod::Stream.new(
      stream_config,
      consumer_config("bottom"),
      producer_config("sink"),
    ).start
  end

  it "affords a diamond topoloy" do
    @source.each do |record|
      @producer.produce(record)
    end

    assert_equal(
      # Doubles of each number raised to the 4th power.
      [1, 1, 16, 16, 81, 81, 256, 256, 625, 625].sort!,
      @sink.sort!
    )
  end

  def producer_config(topic)
    Object.new.tap do |config|
      config.define_singleton_method(:topic_name) { topic }
      config.define_singleton_method(:serialize, &:itself)
    end
  end

  def consumer_config(topic)
    Object.new.tap do |config|
      config.define_singleton_method(:topic_name) { topic }
      config.define_singleton_method(:deserialize, &:itself)
      config.define_singleton_method(:handle_deserialization_error, &:itself)
    end
  end
end
