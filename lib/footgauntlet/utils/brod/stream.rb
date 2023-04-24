# frozen_string_literal: true

require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"
require "footgauntlet/utils/configuration_factory"

module Brod
  class Stream
    Configuration =
      ConfigurationFactory.create(
        :processor,
        :source_topic,
        :source_deserializer,
        :sink_topic,
        :sink_serializer,
        on_source_deserialization_error: -> { raise _1 },
        emit_on_stop: false,
      )

    def initialize(&)
      config = Configuration.new(&)
      @emit_on_stop = config.emit_on_stop

      @producer =
        Producer.new(
          config.sink_topic,
          config.sink_serializer,
        )

      @processor =
        config.processor.new(
          &@producer.method(:produce)
        )

      @consumer =
        Consumer.new(
          config.source_topic,
          config.source_deserializer,
          config.on_source_deserialization_error,
          &@processor.method(:ingest),
        )
    end

    def start
      @producer.start
      @consumer.start
    end

    def stop
      @consumer.stop
      @processor.emit if @emit_on_stop
      @producer.stop
    end
  end
end
