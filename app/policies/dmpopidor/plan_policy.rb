# frozen_string_literal: true

module Dmpopidor
  # Security rules for plan tables
  module PlanPolicy
    def research_outputs?
      @record.readable_by?(@user.id)
    end

    def budget?
      @record.readable_by?(@user.id)
    end

    def create_remote?
      @record.editable_by?(@user.id)
    end

    def sort?
      @record.editable_by?(@user.id)
    end

    def load_values?
      @record.readable_by?(@user.id)
    end

    def import?
      @user.present?
    end

    def import_plan?
      @user.present?
    end
  end
end