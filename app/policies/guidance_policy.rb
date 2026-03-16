# frozen_string_literal: true

# Security rules for guidance
# Note the method names here correspond with controller actions
class GuidancePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Guidance

  def show?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def edit?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def update?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def index?
    @user.can_modify_guidance?
  end

  def new?
    @user.can_modify_guidance?
  end

  def create?
    @user.can_modify_guidance?
  end

  def render_themes?
    @user.can_modify_guidance?
  end

  def destroy?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def publish?
    @user.can_modify_guidance?
  end

  def unpublish?
    @user.can_modify_guidance?
  end
end
