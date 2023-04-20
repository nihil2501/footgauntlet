# frozen_string_literal: true

require "utils/read_only_struct"

module Footgauntlet
  module Core
    module Models
      DailyLeagueSummary =
        ReadOnlyStruct.new(
          :top_ranked_team_points,
          :day_number
        )
    end
  end
end
