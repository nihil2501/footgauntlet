# frozen_string_literal: true

require "footgauntlet/utils/brod/topic"

module Brod
  class Consumer
    DeserializationError = Class.new(RuntimeError)

    # @param config [#topic_name #deserialize #handle_deserialization_error]
    # @yieldparam record [Object]
    # @yieldreturn [void]
    def initialize(config, &consume)
      @config = config
      @topic = Topic.new(@config.topic_name)
      @consume = consume
    end

    # @return [void]
    def start
      @topic.subscribe(
        method(:consume)
      )
    end

    # @return [void]
    def stop
      @topic.unsubscribe(
        method(:consume)
      )
    end

    # @return [String]
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
