# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Security rules for API V1 MadmpFragment endpoints
      class MadmpFragmentsPolicy < ApplicationPolicy
        attr_reader :client, :madmp_fragment

        def show?
          if @user.is_a?(User)
            plan = @record.plan
            plan.readable_by?(@user.id)
          else
            plan = @record.plan
            plan.readable_by_client?(@user.id)
          end
        end

        def dmp_fragments?
          if @user.is_a?(User)
            plan = @record.plan
            plan.readable_by?(@user.id)
          else
            plan = @record.plan
            plan.readable_by_client?(@user.id)
          end
        end

        def update?
          if @user.is_a?(User)
            plan = @record.plan
            plan.editable_by?(@user.id)
          else
            false
          end
        end
      end
    end
  end
end
