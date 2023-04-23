# frozen_string_literal: true

module Footgauntlet
  module Core
    module Models
      MatchdayLeagueSummary =
        Data.define(
          :top_ranked_team_points,
          :matchday_number
        )
    end
  end
end
