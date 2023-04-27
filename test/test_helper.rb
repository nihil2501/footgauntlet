# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "brod_helper"
require "footgauntlet"
require "minitest/autorun"
require "minitest/pride"

# Suppress logger output in specs.
Footgauntlet.logger.reopen(File::NULL)

module Fixture
  class << self
    def open(name)
      path = File.expand_path("fixtures/#{name}", __dir__)
      file = File.open(path, "r")
      file.sync = true
      file
    end
  end
end
