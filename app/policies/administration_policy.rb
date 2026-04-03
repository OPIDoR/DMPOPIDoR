# frozen_string_literal: true

# Security rules for administration
# Note the method names here correspond with controller actions
class AdministrationPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Administration

  def guidances?
    @user.can_modify_guidance?
  end
end
