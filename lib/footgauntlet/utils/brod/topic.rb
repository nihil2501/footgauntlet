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

      def clear
        @subscriptions = nil
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
      log_publish(record)

      @subscriptions.each do |subscription|
        subscription.call(record)
      end
    end

    private

    def log_publish(record)
      # TODO: Fix.
      # `record` may not be guaranteed to `respond_to?(:to_s)`.
      message = record.to_s.strip
      message = { brod: "publish", topic: @name, record: message }

      # 1-level deep `to_json`.
      message = message.to_h.map { |k, v| %{"#{k}": "#{v}"} }
      message = %{{ #{message.join(", ")} }}

      Brod.logger.info(message)
    end
  end
end
