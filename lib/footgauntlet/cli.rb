# frozen_sting_literal: true

module Footgauntlet
  module CLI
    autoload :Options, "footgauntlet/cli/options"
    autoload :Exit, "footgauntlet/cli/exit"
    autoload :Serializer, "footgauntlet/cli/serializer"
    autoload :MatchdayAggregator, "footgauntlet/processor"

    class << self
      def start
        options = Options.parse!

        matchday_aggregator =
          MatchdayAggregator.new do |matchday|
            matchday = Serializer.serialize_matchday(matchday)
            options.output_stream.puts(matchday)
          end

        options.input_stream.each do |game|
          game = Serializer.deserialize_game(game)
          matchday_aggregator.tally_game(game)
        end

        Exit.success!
      end
    end
  end
end
