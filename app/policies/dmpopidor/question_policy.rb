# frozen_string_literal: true

module Dmpopidor
  # Security rules for question tables
  module QuestionPolicy
    def edit?
      if @record.section.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
      end
    end

    def new?
      if @record.section.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
      end
    end

    def create?
      if @record.section.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
      end
    end

    def update?
      if @record.section.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
      end
    end

    def destroy?
      if @record.section.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
      end
    end
  end
end
