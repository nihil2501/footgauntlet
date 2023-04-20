# frozen_sting_literal: true

Encoding.default_external = Encoding::UTF_8

require "footgauntlet/logging"

module Footgauntlet
  autoload :Shell, "footgauntlet/shell"

  class << self
    def logger
      Footgauntlet::Logging.logger
    end
  end
end
