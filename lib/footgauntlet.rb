# frozen_sting_literal: true

Encoding.default_external = Encoding::UTF_8

module Footgauntlet
  autoload :CLI, "footgauntlet/cli"
  autoload :Logging, "footgauntlet/logging"

  class << self
    def logger
      Footgauntlet::Logging.logger
    end
  end
end
