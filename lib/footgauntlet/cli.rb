# frozen_sting_literal: true

require "footgauntlet/cli/exit"
require "footgauntlet/cli/options"
require "footgauntlet/core/streams/league_summary_stream"
require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"

module Footgauntlet
  class CLI
    def initialize
      options = Options.parse!
      Footgauntlet.configure do |config|
        config.log_file = options.log_file
        config.verbose = options.verbose
      end

      @stream = Core::LeagueSummaryStream.new

      @consumer =
        IOConsumer.new(
          @stream.sink_topic_name,
          options.output_stream,
        )

      @producer =
        IOProducer.new(
          @stream.source_topic_name,
          options.input_stream,
        )
    end

    def run
      Signal.trap("INT") do
        shutdown
      end

      Signal.trap("TERM") do
        shutdown
      end

      start
      shutdown
    rescue Error => ex
      stop
      Footgauntlet.logger.fatal "Error: #{ex.message}"
      Exit.error(ex)
    end

    def shutdown
      stop
      Exit.success
    end

    def start
      @stream.start
      @consumer.start
      @producer.start
    end

    def stop
      @producer.stop
      @stream.stop
      @consumer.stop
    end

    class IOProducer < Brod::Producer
      attr_reader :topic_name

      def initialize(topic_name, input_stream)
        @topic_name = topic_name
        @input_stream = input_stream

        super()
      end

      def start
        super

        @input_stream.each do |record|
          produce(record)
        end
      end

      def serialize(record)
        record
      end
    end

    class IOConsumer < Brod::Consumer
      attr_reader :topic_name

      def initialize(topic_name, output_stream)
        @topic_name = topic_name

        super() do |record|
          output_stream.puts(record)
        end
      end

      def deserialize(record)
        record
      end

      def handle_deserialization_error(error)
        # This shouldn't happen.
        raise error
      end
    end
  end
end
