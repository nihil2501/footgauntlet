# frozen_string_literal: true

require "footgauntlet/utils/brod/stream"

module BrodHelpers
  module Stream
    class << self
      def build(processor, source_name, sink_name)
        Brod::Stream.new(
          Config::Stream.new(processor),
          Config::Consumer.new(source_name),
          Config::Producer.new(sink_name),
        )
      end
    end
  end

  module Consumer
    class << self
      def build(topic_name, &consume)
        config = Config::Consumer.new(topic_name)
        Brod::Consumer.new(config, &consume)
      end
    end
  end

  module Producer
    class << self
      def build(topic_name)
        config = Config::Producer.new(topic_name)
        Brod::Producer.new(config)
      end
    end
  end

  module Config
    class Stream
      attr_reader :processor

      def initialize(processor)
        @processor = processor
      end

      def emit_on_stop
        false
      end
    end

    class Producer
      attr_reader :topic_name

      def initialize(topic_name)
        @topic_name = topic_name
      end

      def serialize(record)
        record
      end
    end

    class Consumer
      attr_reader :topic_name

      def initialize(topic_name)
        @topic_name = topic_name
      end

      def deserialize(record)
        record
      end

      def handle_deserialization_error(error)
        # no-op
      end
    end
  end
end
