# frozen_string_literal: true

# Security rules for editing themes
# Note the method names here correspond with controller actions
class ThemePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user

  def index?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    @user.can_super_admin?
  end

  def edit?
    @user.can_super_admin?
  end

  def update?
    @user.can_super_admin?
  end

  def destroy?
    @user.can_super_admin?
  end

  def sort?
    @user.can_super_admin?
  end
end
