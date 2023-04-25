# frozen_string_literal: true

require "logger"

module Brod
  class << self
    attr_writer :logger

    def logger
      @logger ||=
        Logger.new(
          STDERR,
          level: Logger::WARN,
          progname: "Brod"
        )
    end
  end
end
