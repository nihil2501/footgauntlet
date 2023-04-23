# frozen_sting_literal: true

require "footgauntlet/error"
require "footgauntlet/shell/exit"
require "footgauntlet/shell/options"
require "footgauntlet/core/processor"
require "footgauntlet/shell/serialization/game_deserializer"
require "footgauntlet/shell/serialization/matchday_league_summary_serializer"
require "footgauntlet/shell/serialization/deserialization_error"

module Footgauntlet
  module Shell
    class << self
      def start
        options = Options.parse!

        processor =
          Core::Processor.new do |summary|
            output = Serialization::MatchdayLeagueSummarySerializer.perform(summary)
            options.output_stream.puts(output)
          end

        options.input_stream.each do |input|
          game = Serialization::GameDeserializer.perform(input)
          processor.ingest(game)
        rescue Serialization::DeserializationError => ex
          # TODO: Just `warn` this `game` and continue.
        end

        processor.emit

        Exit.success
      rescue Error => ex
        STDERR.puts "Error: #{ex.message}"
        Exit.error(ex)
      end
    end
  end
end
