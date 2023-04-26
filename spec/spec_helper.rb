# frozen_string_literal: true

require "brod_helper"
require "footgauntlet"
require "minitest/pride"

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
