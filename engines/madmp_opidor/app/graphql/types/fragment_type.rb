module Types
  class FragmentType < Types::BaseObject
    field :id, ID, null: false
    field :dmp_id, Integer, null: true
    field :classname, String, null: false
    field :data, GraphQL::Types::JSON, null: true
  end
end
