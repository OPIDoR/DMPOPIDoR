# frozen_string_literal: true

# Security rules for guidance group editing
# Note the method names here correspond with controller actions
class GuidanceGroupPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of GuidanceGroup

  def index?
    @user.can_modify_guidance?
  end

  def show?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def edit?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def update?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def publish?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def unpublish?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def new?
    @user.can_modify_guidance?
  end

  def create?
    @user.can_modify_guidance?
  end

  def destroy?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  # Returns the guidance groups for the specified org
  class Scope < Scope
    def resolve
      scope.where(org_id: @user.org_id)
    end
  end
end
