# frozen_string_literal: true

require "footgauntlet/core/models/team_points"

module Footgauntlet
  module Core
    module Models
      class RankedTeamPoints
        attr_reader :team, :points, :rank

        def initialize(team_points:, rank:)
          @team = team_points.team
          @points = team_points.points
          @rank = rank
        end
      end
    end
  end
end
