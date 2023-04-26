# frozen_string_literal: true

require "footgauntlet/utils/brod/consumer"
require "footgauntlet/utils/brod/producer"

module Brod
  class Stream
    def initialize
      @sink = self.class::Sink.new

      produce = @sink.method(:produce)
      @processor = processor_klass.new(&produce)

      consume = @processor.method(:ingest)
      @source = self.class::Source.new(&consume)

      # Pretty unsure if there are subtle sequencing bugs here in the face of
      # signal traps or exceptions that cause control flow to jump. 
      @stopped = true
    end

    def start
      return unless @stopped
      @stopped = false

      @sink.start
      @source.start
    end

    def stop
      return if @stopped
      @stopped = true

      @source.stop
      @processor.emit if emit_on_stop
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
