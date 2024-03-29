# frozen_sting_literal: true

require "optparse"

module Footgauntlet
  class CLI
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
        :log_file,
        :verbose,
      )

      def initialize
        @input_stream = STDIN
        @output_stream = STDOUT
        @log_file = nil
        @verbose = false

        @parser = OptionParser.new
        @parser.banner = "Usage: footgauntlet [options]"

        on_file("input", "r", "STDIN") { @input_stream = _1 }
        on_file("output", "w", "STDOUT") { @output_stream = _1 }
        on_file("logs", "w", "STDERR") { @log_file = _1 }

        @parser.on("-v", "--verbose", "Run verbosely") do
          @verbose = true
        end

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
          STDERR.puts ex
          STDERR.puts @parser
          Exit.error(ex)
        end

        @input_stream.sync = true
        @output_stream.sync = true
      end

      private

      def on_file(name, mode, default)
        args = [
           "-#{name[0]}", # `short_name`
           "--#{name} #{name.upcase}", # `long_name`
           "Path to #{name} file (defaults to #{default})", # `description`
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

