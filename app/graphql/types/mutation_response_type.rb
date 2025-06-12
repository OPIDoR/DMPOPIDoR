module Types
  class MutationResponseType < BaseObject
    field :code, Integer, null: false
    field :message, String, null: false
    field :success, Boolean, null: false
  end
end
