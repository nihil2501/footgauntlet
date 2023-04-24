# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Producer
    def initialize(topic_name, serializer)
      @topic = Topic.new(topic_name)
      @serializer = serializer
      @stopped = true
    end

    def produce(record)
      return if @stopped
      record = @serializer.call(record)
      @topic.publish(record)
    end

    def start
      @stopped = false
    end

    def stop
      @stopped = true
    end
  end
end
