# frozen_sting_literal: true

require "footgauntlet/error"
require "footgauntlet/shell/exit"
require "footgauntlet/shell/options"
require "footgauntlet/shell/processor"

module Footgauntlet
  module Shell
    class << self
      def start
        options = Options.parse!
        Processor.start(options)
        Exit.success
      rescue Error => ex
        STDERR.puts "Error: #{ex.message}"
        Exit.error(ex)
      end
    end
  end
end
