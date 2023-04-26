# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Producer
    def initialize
      @topic = Topic.new(topic_name)
      @stopped = true
    end

    def produce(record)
      return if @stopped
      record = serialize(record)
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
