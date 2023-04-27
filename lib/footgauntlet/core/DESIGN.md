# Footgauntlet Core
Footgauntlet core consists of stream processors built from the simple `Brod` 
stream processing framework. Processors contain the domain logic. They have an
`ingest` method for taking in a record and are initialized with a block that is
called when they want to emit a new fact. Processors should be placed in the
`processors` directory. Streams then attach these processors to particular
source and sink topics and specify how to deserialize into and serialize out of
the processor. Streams should be placed in the `streams` directory. With these
streams defined in core, shell applications can start them and feed facts into
the appropriate topics from the outside world.
The details of using the `Brod` framework can be found at:
`lib/footgauntlet/utils/brod/DESIGN.md`

```ruby
class MyProcessor
  def initialize(&on_emit)
    @on_emit = on_emit
  end

  def ingest(record)
    @on_emit.call(record)
  end
end

class MyStream
  class << self
    def build
      Brod::Stream.new(
        Config::Stream.new,
        Config::Source.new,
        Config::Sink.new,
      )
    end
  end

  module Config
    class Stream
      def processor
        MyProcessor
      end

      def emit_on_stop
        false
      end
    end

    class Source
      def topic_name
        "source"
      end

      def deserialize(record)
        record
      end

      def handle_deserialization_error(error)
        Footgauntlet.logger.warn(error)
      end
    end

    class Sink
      def topic_name
        "sink"
      end

      def serialize(record)
        record
      end
    end
  end
end
```