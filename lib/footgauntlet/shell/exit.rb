# frozen_sting_literal: true

require "footgauntlet/error"
require "footgauntlet/shell/options"

module Footgauntlet
  module Shell
    module Exit
      class << self
        def success
          exit(0)
        end

        def error(ex)
          code =
            case ex
            when OptionsError
              2
            when Error
              1
            end

          exit(code)
        end
      end
    end
  end
end
