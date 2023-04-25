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

      @stream = Core::LeagueSummaryStream

      consume =
        lambda do |record|
          options.output_stream.puts(record)
        end

      @consumer =
        Brod::Consumer.new(
          @stream.sink_topic_name,
          :itself.to_proc, -> {},
          consume
        )

      @producer =
        Brod::Producer.new(
          @stream.source_topic_name,
          :itself.to_proc
        )

      @run_proc =
        lambda do
          options.input_stream.each do |record|
            @producer.produce(record)
          end
        end
    end

    def run
      Signal.trap("INT") do
        shutdown
      end

      Signal.trap("TERM") do
        shutdown
      end

      start
      @run_proc.call
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
  end
end
