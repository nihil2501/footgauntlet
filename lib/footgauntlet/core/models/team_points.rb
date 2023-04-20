# frozen_string_literal: true

module Footgauntlet
  module Core
    module Models
      class TeamPoints
        attr_reader :team, :points

        def initialize(team:)
          @team = team
          @points = 0
        end

        def tally(value)
          @points += value
        end
      end
    end
  end
end