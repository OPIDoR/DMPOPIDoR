# frozen_string_literal: true

# Security rules for questions
# Note the method names here correspond with controller actions
class QuestionPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Question

  ##
  # Users can modify questions if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##
  def index?
    @user.present?
  end

  def show?
    @user.present?
  end

  def open_conditions?
    @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
  end

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

  # TODO: Remove this after annotations controller is refactored
  def admin_update?
    @user.can_modify_templates? && (@record.section.phase.template.org_id == @user.org_id)
  end
end
