# frozen_sting_literal: true

require "footgauntlet/error"
require "footgauntlet/cli/exit"
require "footgauntlet/cli/options"
require "footgauntlet/core/streams/league_summary_stream"
require "footgauntlet/utils/pubsub"

module Footgauntlet
  module CLI
    class << self
      def start
        options = Options.parse!

        stream = Core::LeagueSummaryStream
        stream.start

        Pubsub.subscribe(stream.sink_topic) do |record|
          options.output_stream.puts(record)
        end

        options.input_stream.each do |record|
          Pubsub.publish(stream.source_topic, record)
        end

        stream.stop

        Exit.success
      rescue Error => ex
        STDERR.puts "Error: #{ex.message}"
        Exit.error(ex)
      end
    end
  end
end
