# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Consumer
    DeserializationError = Class.new(RuntimeError)

    def initialize(&consume)
      @topic = Topic.new(topic_name)
      @consume = consume
    end

    def start
      @topic.subscribe(method(:consume))
    end

    def stop
      @topic.unsubscribe(method(:consume))
    end

    def consume(record)
      record = deserialize(record)
      @consume.call(record)
    rescue DeserializationError => ex
      handle_deserialization_error(ex)
    end
  end
end
