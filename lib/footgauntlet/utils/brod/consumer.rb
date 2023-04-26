# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Consumer
    DeserializationError = Class.new(RuntimeError)

    def initialize(config, &consume)
      @config = config
      @topic = Topic.new(@config.topic_name)
      @consume = consume
    end

    def start
      @topic.subscribe(
        method(:consume)
      )
    end

    def stop
      @topic.unsubscribe(
        method(:consume)
      )
    end

    def topic_name
      @topic.name
    end

    private

    def consume(record)
      record = @config.deserialize(record)
      @consume.call(record)
    rescue DeserializationError => ex
      @config.handle_deserialization_error(ex)
    end
  end
end
