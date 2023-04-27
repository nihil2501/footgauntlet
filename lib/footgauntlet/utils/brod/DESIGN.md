# Brod
### A Simple Stream Processing Framework

![Here he is](https://upload.wikimedia.org/wikipedia/commons/6/66/Max_Brod_v_roce_1914.jpg)

Max `Brod` was the best friend of Franz Kafka. His literary stature is lesser,
and his last name is shorter. He __published__ Franz's works... _Get it?_

> The quiet Kafka "would have been... hard to notice... even his elegant,
> usually dark-blue, suits were inconspicuous and reserved like him. At that
> time, however, something seems to have attracted him to me, he was more open
> than usual, filling the endless walk home by disagreeing strongly with my all
> too rough formulations."
>
> — [Max Brod](https://en.wikipedia.org/wiki/Max_Brod#cite_note-4)

Brod has topics that can be published and subscribed to. Topics are consumed by
consumers, produced by producers, and can be streamed between by streams which
are a convenience that combines a consumer and a producer with a processor.

One can build up topologies that look like this:
```


                       ,--Stream-->[top]--Stream-----,
                       |                             |
  Producer-->[source]--|                             |-->[sink]-->Consumer
                       |                             |
                       '--Stream-->[bottom]--Stream--'


```

### Producers
To make your own producer, you must specify a topic to produce to and a method
to serialize onto the topic by passing in a configuration object that implements
these methods.

```ruby
class Config
  def topic_name
    "topic"
  end

  def serialize(record)
    record
  end
end

config = Config.new

producer = Brod::Producer.new(config)
```

You can change whether a producer has its normal behavior or no-ops.

```ruby
producer.start
producer.stop
```


### Consumers
To make your own consumer, you must specify a topic to consume from, a method
to deserialize off of the topic, and a handler for occurrences of
deserialization errors. Again, this is done by passing in a configuration object
with these methods. When initializing a consumer, you provide a block that is
called when there is a new fact that has been published to the topic.

```ruby
class Config
  def topic_name
    "topic"
  end

  def deserialize(record)
    record
  end

  def handle_deserialization_error(error)
    Brod.logger.warn(error)
  end
end

config = Config.new

consumer =
  Brod::Consumer(config) do |record|
    Brod.logger.info(record)
  end
```

You can also control when a consumer subscribes and unsubcribes from a topic.

```ruby
consumer.start
consumer.stop
```

### Streams
To make a stream processor that processes facts between a source topic and sink
topic one must supply the two aformentioned kinds of configuration as well as
another configuration specifying the behavior surrounding the processor itself.
A processor in turn needs to have an `ingest` instance method and be initialized
with a block that will be called when the processor is compelled to emit some
fact.

```ruby
class Processor
  def initialize(&on_emit)
    @on_emit = on_emit
  end

  def ingest(record)
    @on_emit.call(record)
  end
end

class Config
  def processor
    Processor
  end

  def emit_on_stop
    false
  end
end

stream_config = Config.new

stream =
  Brod::Stream.new(
    stream_config,
    source_config,
    sink_config
  )
```

A stream can be started or stopped as well. A stream has a special piece of
configuration that says whether it should emit the fact it derives from its
internal state when it is stopped.

```ruby
stream.start
stream.stop
```
