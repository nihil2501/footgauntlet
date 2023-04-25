# frozen_sting_literal: true

Encoding.default_external = Encoding::UTF_8

require "footgauntlet/utils/brod"
require "footgauntlet/utils/configuration_factory"
require "logger"

module Footgauntlet
  autoload :CLI, "footgauntlet/cli"

  Error = Class.new(RuntimeError)

  Configuration =
    ConfigurationFactory.create(
      log_level: Logger::WARN,
      logdev: STDERR,
    )

  class << self
    attr_reader :logger

    def configure(&)
      config = Configuration.new(&)
      base_formatter = Logger::Formatter.new

      formatter =
        Proc.new do |*args, message|
          if message.respond_to?(:to_h)
            # 1-level deep `to_json`.
            message = message.to_h.map { |k, v| %{"#{k}": "#{v}"}}
            message = %{{ #{message.join(", ")} }}
          end

          base_formatter.call(
            *args,
            message
          )
        end

      @logger =
        Logger.new(
          config.logdev,
          level: config.log_level,
          progname: "Footgauntlet",
          formatter:,
        )

      Brod.logger = @logger
    end
  end
end
