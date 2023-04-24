# frozen_string_literal: true

module Pubsub
  class << self
    def subscribe(topic, &block)
      topic_subscribers[topic] << block
    end

    def publish(topic, record)
      subscribers = topic_subscribers[topic]
      subscribers.each do |block|
        block.call(record)
      end
    end

    private

    def topic_subscribers
      @topic_subscribers ||=
        Hash.new do |memo, topic|
          memo[topic] = []
        end
    end
  end
end