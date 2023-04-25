# frozen_string_literal: true

require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"
require "footgauntlet/utils/configuration_factory"

module Brod
  class Stream
    Configuration =
      ConfigurationFactory.create(
        :processor,
        :source_topic_name,
        :source_deserializer,
        :sink_topic_name,
        :sink_serializer,
        on_source_deserialization_error: -> { raise _1 },
        emit_on_stop: false,
      )

    def initialize(&)
      config = Configuration.new(&)
      @emit_on_stop = config.emit_on_stop

      @producer =
        Producer.new(
          config.sink_topic_name,
          config.sink_serializer,
        )

      @processor =
        config.processor.new(
          &@producer.method(:produce)
        )

      @consumer =
        Consumer.new(
          config.source_topic_name,
          config.source_deserializer,
          config.on_source_deserialization_error,
          &@processor.method(:ingest)
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

    def source_topic_name
      @consumer.topic_name
    end

    def sink_topic_name
      @producer.topic_name
    end
  end
end
