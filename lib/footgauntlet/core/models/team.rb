# frozen_string_literal: true

module Footgauntlet
  module Core
    module Models
      # This receives its `hash` function from `Data`. It is a pure
      # calculation of its `members`' `hash` functions, which is exactly what
      # we want.
      Team = Data.define(:name)
    end
  end
end