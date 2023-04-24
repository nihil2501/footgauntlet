# frozen_sting_literal: true

Encoding.default_external = Encoding::UTF_8

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

      @logger =
        Logger.new(
          config.logdev,
          level: config.log_level,
          progname: "Footgauntlet"
        )
    end
  end
end
