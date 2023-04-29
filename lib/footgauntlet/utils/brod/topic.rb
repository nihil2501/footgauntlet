# frozen_string_literal: true

module Brod
  # Represents a topic in a publish-subscribe pattern for message distribution.
  class Topic
    class << self
      # @return [Hash{String => Array<Proc>}]
      def subscriptions
        @subscriptions ||=
          Hash.new do |memo, topic|
            memo[topic] = []
          end
      end

      # Clears all subscriptions.
      # return [void]
      def clear
        @subscriptions = nil
      end
    end

    # @return [String]
    attr_reader :name

    # @param name [String]
    def initialize(name)
      @subscriptions = Topic.subscriptions[name]
      @name = name
    end

    # @param subscription [Proc]
    # @return [void]
    def subscribe(subscription)
      @subscriptions << subscription
    end

    # @param subscription [Proc]
    # @return [void]
    def unsubscribe(subscription)
      @subscriptions.delete(subscription)
    end

    # @param record [Object]
    # @return [void]
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
