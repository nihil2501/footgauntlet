# frozen_string_literal: true

module Footgauntlet
  module Core
    class TeamPoints
      attr_reader :team, :points

      def initialize(team:)
        @team = team
        @points = 0
      end

      def award(value)
        @points += value
      end
    end
  end
end