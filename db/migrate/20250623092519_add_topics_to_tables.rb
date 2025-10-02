class AddTopicsToTables < ActiveRecord::Migration[7.2]
  def change
    add_column :registries, :topics, :string, array: true, null: false, default: ["generic"]
    add_column :guidance_groups, :topics, :string, array: true, null: false, default: ["generic"]
    add_column :madmp_schemas, :topics, :string, array: true, null: false, default: ["generic"]

    add_column :research_outputs, :topic, :string, null: false, default: "generic"

  end
end
