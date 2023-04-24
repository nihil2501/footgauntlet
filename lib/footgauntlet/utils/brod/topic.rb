# frozen_string_literal: true

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

    def initialize(name)
      @subscriptions = self.class.subscriptions[name]
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
end
