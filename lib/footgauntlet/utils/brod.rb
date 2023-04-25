# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"

module Brod
  class Topic
    class << self
      def subscriptions
        @subscriptions ||=
          Hash.new do |memo, topic|
            memo[topic] = []
          end
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
      @subscriptions = self.class.subscriptions[@name]
    end

    def subscribe(&subscription)
      @subscriptions << subscription
    end

    def unsubscribe(&subscription)
      @subscriptions.delete(subscription)
    end

    def publish(record)
      @subscriptions.each do |subscription|
        subscription.call(record)
      end
    end
  end

  class Consumer
    DeserializationError = Class.new(RuntimeError)

    def initialize(topic_name, deserializer, on_deserialization_error, &consume)
      @topic = Topic.new(topic_name)
      @consume =
        proc do |record|
          record = deserializer.call(record)
          consume.call(record)
        rescue DeserializationError => ex
          on_deserialization_error.call(ex)
        end
    end

    def start = @topic.subscribe(&@consume)
    def stop = @topic.unsubscribe(&@consume)
    def topic_name = @topic.name
  end

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

    def start = @stopped = false
    def stop = @stopped = true
    def topic_name = @topic.name
  end

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

    def source_topic_name = @consumer.topic_name
    def sink_topic_name = @producer.topic_name
  end
end
