# frozen_string_literal: true

require "spec_helper"

describe Footgauntlet::CLI do
  describe "#run" do
    options =
      Module.new do
        class << self
          def input_stream
            @input_stream ||= Fixture.open("input.txt")
          end

          def output_stream
            @output_stream ||= StringIO.new
          end

          def log_file
            nil
          end

          def verbose
            false
          end
        end
      end

    it "produces the specified output stream" do
      Footgauntlet::CLI::Exit.stub(:success, options) do
        Footgauntlet::CLI::Options.stub(:parse!, options) do
          Footgauntlet::CLI.new.run

          expected = Fixture.open("output.txt").read.tap(&:strip!)
          actual = options.output_stream.tap(&:rewind).read.tap(&:strip!)

          assert_equal(
            expected,
            actual
          )
        end
      end
    end
  end
end
