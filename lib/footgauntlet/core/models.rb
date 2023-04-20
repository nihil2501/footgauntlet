# frozen_string_literal: true

require "set"

module Footgauntlet
  module Core
    module Models
      class ReadOnlyStruct < Struct
        class << self
          def new(*args)
            super(*args, keyword_init: true).tap do |klass|
              klass.undef_method :[]=
              klass.members.each do |member|
                klass.undef_method :"#{member}="
              end
            end
          end
        end
      end

      Team =
        ReadOnlyStruct.new(
          :name
        )

      TeamScore =
        ReadOnlyStruct.new(
          :team,
          :score
        )

      Game =
        ReadOnlyStruct.new(:home_score, :away_score) do
          def teams
            @teams ||= Set[
              home_score.team,
              away_score.team
            ]
          end

          def winner
            compare
            @winner
          end

          def loser
            compare
            @loser
          end

          def tied?
            compare
            @winner.nil?
          end

          private

          def compare
            return if @comparison
            @comparison =
              home_score.score <=>
                away_score.score

            case @comparison
            when 1
              @winner = home_score.team
              @loser = away_score.team
            when -1
              @winner = away_score.team
              @loser = home_score.team
            end
          end
        end

      TeamPoints =
        ReadOnlyStruct.new(
          :team,
          :points
        )

      Matchday =
        ReadOnlyStruct.new(
          :top_team_points,
          :index,
        )
    end
  end
end
