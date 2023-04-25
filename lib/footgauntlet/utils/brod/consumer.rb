# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Consumer
    DeserializationError = Class.new(RuntimeError)

    def initialize(topic_name, deserializer, on_deserialization_error, consume)
      @topic = Topic.new(topic_name)
      @consume =
        lambda do |record|
          record = deserializer.call(record)
          consume.call(record)
        rescue DeserializationError => ex
          on_deserialization_error.call(ex)
        end
    end

    def start
      @topic.subscribe(@consume)
    end

    def stop
      @topic.unsubscribe(@consume)
    end

    def topic_name
      @topic.name
    end
  end
end
