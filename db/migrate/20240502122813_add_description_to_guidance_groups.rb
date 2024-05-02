class AddDescriptionToGuidanceGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :guidance_groups, :description, :string
  end
end
