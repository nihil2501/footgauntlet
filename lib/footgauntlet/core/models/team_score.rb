# frozen_string_literal: true

module Footgauntlet
  module Core
    module Models
      TeamScore =
        Data.define(
          :team,
          :score
        )
    end
  end
end