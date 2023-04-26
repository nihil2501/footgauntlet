# frozen_sting_literal: true

require "footgauntlet/cli/exit"
require "footgauntlet/cli/io"
require "footgauntlet/cli/options"
require "footgauntlet/core/streams/league_summary_stream"

module Footgauntlet
  class CLI
    def initialize
      options = Options.parse!
      @input_stream = options.input_stream

      Footgauntlet.configure do |config|
        config.log_file = options.log_file
        config.verbose = options.verbose
      end

      @stream = Core::LeagueSummaryStream.build

      @consumer =
        IO::Consumer.new(
          @stream.sink_topic_name,
          options.output_stream,
        )

      @producer =
        IO::Producer.new(
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

    def start
      @stream.start
      @consumer.start
      @producer.start
    end

    def shutdown
      stop
      Exit.success
    end

    def stop
      @producer.stop
      @stream.stop
      @consumer.stop
    end
  end
end
