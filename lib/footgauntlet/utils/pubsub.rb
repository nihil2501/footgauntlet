# frozen_string_literal: true

module Pubsub
  class << self
    def subscribe(topic, &subscription)
      topic_subscriptions[topic] << subscription
    end

    def publish(topic, record)
      subscriptions = topic_subscriptions[topic]
      subscriptions.each do |subscription|
        subscription.(record)
      end
    end

    private

    def topic_subscriptions
      @topic_subscriptions ||=
        Hash.new do |memo, topic|
          memo[topic] = []
        end
    end
  end
end