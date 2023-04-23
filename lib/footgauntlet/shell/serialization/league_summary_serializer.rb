# frozen_string_literal: true

module Footgauntlet
  module Shell
    module Serialization
      module LeagueSummarySerializer
        class << self
          def serialize(summary)
            String.new.tap do |memo|
              memo << "Matchday #{summary.matchday_number}\n"

              summary.ranking.each do |ranked_team_points|
                name = ranked_team_points.team.name
                points = ranked_team_points.points
                unit = points == 1 ? "pt" : "pts"

                # Rank is currently unused but nonetheless appears barely
                # unambiguously enough in the spec.
                memo << "#{name}, #{points} #{unit}\n"
              end

              memo << "\n"
            end
          end
        end
      end
    end
  end
end
