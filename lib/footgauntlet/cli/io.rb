# frozen_sting_literal: true

require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"

module Footgauntlet
  class CLI
    module IO
      class Consumer < Brod::Consumer
        def initialize(topic_name, output_stream)
          config = Config.new(topic_name)
          super(config) do |record|
            output_stream.puts(record)
          end
        end

        class Config
          attr_reader :topic_name

          def initialize(topic_name)
            @topic_name = topic_name
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

      class Producer < Brod::Producer
        def initialize(topic_name, input_stream)
          @input_stream = input_stream
          config = Config.new(topic_name)
          super(config)
        end

        def start
          super

          @input_stream.each do |record|
            produce(record)
          end
        end

        class Config
          attr_reader :topic_name

          def initialize(topic_name)
            @topic_name = topic_name
          end

          def serialize(record)
            record
          end
        end
      end
    end
  end
end

