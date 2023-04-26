# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Producer
    def initialize(config)
      @config = config
      @topic = Topic.new(@config.topic_name)
      @stopped = true
    end

    def produce(record)
      return if @stopped
      record = @config.serialize(record)
      @topic.publish(record)
    end

    def start
      @stopped = false
    end

    def stop
      @stopped = true
    end

    def topic_name
      @topic.name
    end
  end
end
