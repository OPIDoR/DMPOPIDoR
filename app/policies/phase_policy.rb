# frozen_string_literal: true

# Security rules for template phases
# Note the method names here correspond with controller actions
class PhasePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Phase

  ##
  # Org-admin side
  # Users can modify phases if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org

  def show?
    if @record.template.module?
      @user.can_super_admin?
    else
      @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
    end
  end

  def preview?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
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

  def sort?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end
end
