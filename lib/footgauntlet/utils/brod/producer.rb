# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Producer
    # @param config [#topic_name #serialize]
    def initialize(config)
      @config = config
      @topic = Topic.new(@config.topic_name)
      @stopped = true
    end

    # @param record [Object]
    # @return [void]
    def produce(record)
      return if @stopped
      record = @config.serialize(record)
      @topic.publish(record)
    end

    # @return [void]
    def start
      @stopped = false
    end

    # @return [void]
    def stop
      @stopped = true
    end

    # @return [String]
    def topic_name
      @topic.name
    end
  end
end
