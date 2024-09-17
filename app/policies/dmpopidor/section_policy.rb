# frozen_string_literal: true

module Dmpopidor
  # Security rules for section tables
  module SectionPolicy
    def edit?
      if @record.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def new?
      if @record.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def create?
      if @record.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def update?
      if @record.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def destroy?
      if @record.phase.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  end
end
