# frozen_sting_literal: true

Encoding.default_external = Encoding::UTF_8

require "footgauntlet/logging"

module Footgauntlet
  autoload :CLI, "footgauntlet/cli"

  class << self
    def logger
      Footgauntlet::Logging.logger
    end
  end
end
