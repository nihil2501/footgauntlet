# frozen_sting_literal: true

# Is there any good way to remove dependency on `Exit` in `Options`?
require "footgauntlet/cli/exit"
require "footgauntlet/error"
require "optparse"

module Footgauntlet
  module CLI
    class Options
      OptionsError = Class.new(Error)
      DuplicateFilePathError = Class.new(OptionsError)
      ParseError = Class.new(OptionsError)

      class << self
        alias_method :parse!, :new
        undef_method :new
      end

      attr_reader(
        :input_stream,
        :output_stream,
        :log,
      )

      def initialize
        @input_stream = STDIN
        @output_stream = STDOUT
        @log = STDERR

        @parser = OptionParser.new
        @parser.banner = "Usage: footgauntlet [options]"

        # TODO: How to set mode re: recovery? How to do recovery / fault
        # tolerance in general?
        on_file("input", "r") { @input_stream = _1 }
        on_file("output", "w") { @output_stream = _1 }
        on_file("logs", "w") { @log = _1 }

        @parser.on("-h", "--help", "Prints this help message") do
          STDERR.puts @parser
          Exit.success
        end

        begin
          begin
            @parser.parse!
          rescue OptionParser::ParseError => ex
            # Wrapped and handled by base error handler for this class below.
            # Is there a better patern that doesn't involve nesting `begin`s?
            raise ParseError, ex.message
          end
        rescue OptionsError => ex
          STDERR.puts @parser
          raise ex
        end

        # TODO: Vet tradeoffs of synced vs buffered for each IO.
        @input_stream.sync = true
        @output_stream.sync = true
        @log.sync = true
      end

      private

      def on_file(name, mode)
        args = [
           "-#{name[0]}", # `short_name`
           "--#{name} #{name.upcase}", # `long_name`
           "Path to #{name} file", # `description`
        ]

        @parser.on(*args) do |path|
          @file_paths ||= Set[]
          unless @file_paths.add?(path)
            error_message = "File path used more than once: `#{path}'"
            raise DuplicateFilePathError, error_message
          end

          file = File.open(path, mode)
          yield(file)
        end
      end
    end
  end
end
