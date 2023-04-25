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
      :log_file,
      :verbose,
    )

  DEFAULT_LOG_LEVEL = Logger::WARN

  class << self
    def configure(&)
      config = Configuration.new(&)
      log_level = config.verbose ? Logger::INFO : DEFAULT_LOG_LEVEL

      if config.log_file.nil?
        logger.level = log_level
      else
        set_logger(config.log_file, log_level)
      end
    end

    def logger
      @logger ||= set_logger
    end

    def set_logger(logdev = STDERR, level = DEFAULT_LOG_LEVEL)
      @logger_formatter ||= begin
        base = Logger::Formatter.new
        Proc.new do |*args, message|
          if message.respond_to?(:to_h)
            # 1-level deep `to_json`.
            message = message.to_h.map { |k, v| %{"#{k}": "#{v}"} }
            message = %{{ #{message.join(", ")} }}
          end

          base.call(
            *args,
            message
          )
        end
      end

      @logger =
        Logger.new(logdev,
          formatter: @logger_formatter,
          progname: self.name,
          level:,
        )

      Brod.logger = @logger
      @logger
    end
  end
end
