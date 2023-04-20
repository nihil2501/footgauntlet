# frozen_string_literal: true

require "utils/read_only_struct"

module Footgauntlet
  module Core
    module Models
      TeamScore =
        ReadOnlyStruct.new(
          :team,
          :score
        )
    end
  end
end