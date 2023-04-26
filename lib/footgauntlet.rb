# frozen_sting_literal: true

require "footgauntlet/utils/brod"
require "footgauntlet/utils/configuration_factory"
require "logger"

module Footgauntlet
  autoload :CLI, "footgauntlet/cli"

  Error = Class.new(RuntimeError)

  Configuration =
    ConfigurationFactory.create(
      :log_file,
      :verbose,
    )

  class << self
    def configure(&)
      config = Configuration.new(&)
      logger.level = config.verbose ? Logger::INFO : Logger::WARN
      logger.reopen(config.log_file)
    end

    def logger
      @logger ||= begin
        memo = Logger.new(STDERR, level: Logger::WARN, progname: name)
        Brod.logger = memo
      end
    end
  end
end
