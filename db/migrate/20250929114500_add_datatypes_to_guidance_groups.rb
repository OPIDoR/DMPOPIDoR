class AddDatatypesToGuidanceGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :guidance_groups, :data_types, :string, array: true, null: false, default: ['none']
  end
end
