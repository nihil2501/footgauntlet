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
      if @logger.nil?
        progname = self.name
        base_formatter = Logger::Formatter.new
        formatter =
          Proc.new do |*args, message|
            if message.respond_to?(:to_h)
              # 1-level deep `to_json`.
              message = message.to_h.map { |k, v| %{"#{k}": "#{v}"} }
              message = %{{ #{message.join(", ")} }}
            end

            base_formatter.call(
              *args,
              message
            )
          end

        @logger =
          Logger.new(STDERR,
            level: Logger::WARN,
            progname:,
            formatter:,
          )

        Brod.logger = @logger
      end

      @logger
    end
  end
end
