# frozen_sting_literal: true

module Footgauntlet
  class CLI
    module Exit
      class << self
        def success
          exit(0)
        end

        def error(ex)
          code =
            case ex
            when Options::OptionsError
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
