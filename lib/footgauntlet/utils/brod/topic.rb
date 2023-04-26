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

    attr_reader :name

    def initialize(name)
      @subscriptions = Topic.subscriptions[name]
      @name = name
    end

    def subscribe(subscription)
      @subscriptions << subscription
    end

    def unsubscribe(subscription)
      @subscriptions.delete(subscription)
    end

    def publish(record)
      Brod.logger.info({
        brod: "publish",
        topic: @name,
        record: record.strip,
      })

      @subscriptions.each do |subscription|
        subscription.call(record)
      end
    end
  end
end
