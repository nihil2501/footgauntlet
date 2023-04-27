# frozen_string_literal: true

require "footgauntlet/core/streams/league_summary_stream"
require "test_helper"

describe Footgauntlet::Core::LeagueSummaryStream do
  before do
    # TODO: It'd be nice for this to happen automatically otherwise we have a
    # footgun in our footgauntlet.
    Brod::Topic.clear

    @sink = []

    stream = Footgauntlet::Core::LeagueSummaryStream.build
    @producer = BrodHelpers::Producer.build(stream.source_topic_name)
    consumer = BrodHelpers::Consumer.build(stream.sink_topic_name) do |record|
      @sink << record
    end

    stream.start
    consumer.start
    @producer.start
  end

  describe "when there is an unparseable record" do
    before do
      @source = [
        "unparseable record",
        "San Jose Earthquakes 3, Santa Cruz Slugs 3",
        "San Jose Earthquakes 3, Santa Cruz Slugs 3",
      ]
    end

    describe "logging behavior" do
      before do
        @warn_logs = []
      end

      it "warn-logs the unparseable record but continues processing" do
        Footgauntlet.logger.stub :warn, -> { @warn_logs << _1 } do
          produce_source

          expected_logs = [[Brod::Consumer::DeserializationError, "unparseable record"]]
          actual_logs = @warn_logs.map { |ex| [ex.class, ex.message] }

          assert_equal(
            expected_logs,
            actual_logs
          )

          expected_sink = ["Matchday 1 San Jose Earthquakes, 1 pt Santa Cruz Slugs, 1 pt"]
          actual_sink = @sink.map { |record| record.gsub("\n", " ").strip }

          assert_equal(
            expected_sink,
            actual_sink
          )
        end
      end
    end
  end

  def produce_source
    @source.each do |record|
      @producer.produce(record)
    end
  end
end
