# frozen_string_literal: true

require "utils/read_only_struct"

module Footgauntlet
  module Core
    module Models
      # This receives its `hash` function from `Struct`. It is a pure
      # calculation of its `members`' `hash` functions, which is exactly what
      # we want.
      Team =
        ReadOnlyStruct.new(
          :name
        )
    end
  end
end