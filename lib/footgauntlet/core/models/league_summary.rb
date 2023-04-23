# frozen_string_literal: true

module Footgauntlet
  module Core
    module Models
      LeagueSummary =
        Data.define(
          :top_ranked_team_points,
          :matchday_count
        )
    end
  end
end
