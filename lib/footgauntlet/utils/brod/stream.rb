# frozen_string_literal: true

require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"

module Brod
  # A class to manage a data stream, which includes a source, a processor, and a
  # sink.
  class Stream
    # @param stream_config [#processor #emit_on_stop]
    # @param source_config (see Brod::Consumer#initialize)
    # @param sink_config (see Brod::Producer#initialize)
    def initialize(stream_config, source_config, sink_config)
      # Pretty unsure if there are subtle sequencing bugs here in the face of
      # signal traps or exceptions that cause control flow to jump. 
      @stopped = true
      @emit_on_stop = stream_config.emit_on_stop

      @sink = Producer.new(sink_config)

      @processor =
        stream_config.processor.new do |record|
          @sink.produce(record)
        end

      @source =
        Consumer.new(source_config) do |record|
          @processor.ingest(record)
        end
    end

    # @return [void]
    def start
      return unless @stopped
      @stopped = false

      @sink.start
      @source.start
    end

    # @return [void]
    def stop
      return if @stopped
      @stopped = true

      @source.stop
      @processor.emit if @emit_on_stop
      @sink.stop
    end

    def source_topic_name
      @source.topic_name
    end

    def sink_topic_name
      @sink.topic_name
    end
  end
end
