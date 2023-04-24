# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"
require "footgauntlet/utils/pubsub"

class Stream
  Error = Class.new(RuntimeError)
  DeserializationError = Class.new(Error)

  Configuration =
    ConfigurationFactory.create(
      :processor,
      :source_topic,
      :source_deserializer,
      :sink_topic,
      :sink_serializer,
      emit_on_stop: false
    )

  def initialize(&)
    @config = Configuration.new(&)
  end

  def start
    Pubsub.subscribe(@config.source_topic) do |record|
      record = @config.source_deserializer.(record)
      processor.ingest(record)
    rescue DeserializationError => ex
      # TODO: Just `warn` this `record` and continue. For this I may need to
      # allow this library to get hooked up with a logger. Is pubsub yet another
      # library that should be able to get hooked up with a logger?
    end
  end

  def stop
    if @config.emit_on_stop
      processor.emit
    end
  end

  def source_topic
    @config.source_topic
  end

  def sink_topic
    @config.sink_topic
  end

  private

  def processor
    @processor ||= 
      @config.processor.new do |record|
        record = @config.sink_serializer.(record)
        Pubsub.publish(@config.sink_topic, record)
      end
  end
end
