# frozen_sting_literal: true

require "footgauntlet/cli/exit"
require "footgauntlet/cli/options"
require "footgauntlet/core/streams/league_summary_stream"
require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"

module Footgauntlet
  module CLI
    class << self
      def start
        options = Options.parse!
        Footgauntlet.configure do |config|
          config.log_file = options.log_file
          config.verbose = options.verbose
        end

        stream = Core::LeagueSummaryStream

        consume =
          lambda do |record|
            options.output_stream.puts(record)
          end

        consumer =
          Brod::Consumer.new(
            stream.sink_topic_name,
            :itself.to_proc, -> {},
            &consume
          )

        producer =
          Brod::Producer.new(
            stream.source_topic_name,
            :itself.to_proc
          )

        stream.start
        consumer.start
        producer.start

        options.input_stream.each do |record|
          producer.produce(record)
        end

        producer.stop
        stream.stop
        consumer.stop

        Exit.success
      rescue Error => ex
        Footgauntlet.logger.fatal "Error: #{ex.message}"
        Exit.error(ex)
      end
    end
  end
end
