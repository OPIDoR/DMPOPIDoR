class AddIsDefaultToGuidanceGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :guidance_groups, :is_default, :boolean, null: false, default: false
  end
end
