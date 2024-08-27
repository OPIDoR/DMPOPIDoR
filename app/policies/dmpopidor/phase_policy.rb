# frozen_string_literal: true

module Dmpopidor
  # Security rules for phase tables
  module PhasePolicy
    def show?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end

    def edit?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def update?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def new?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def create?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  
    def destroy?
      if @record.template.module?
        @user.can_super_admin?
      else
        @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
      end
    end
  end
end
