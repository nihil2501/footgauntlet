# frozen_sting_literal: true

module Footgauntlet
  module CLI
    module Exit
      class << self
        private def define_reason_code(reason, code)
          define_singleton_method(:"#{reason}!") do
            exit code
          end
        end
      end

      define_reason_code :success, 0
      define_reason_code :options_invalid, 2
    end
  end
end
