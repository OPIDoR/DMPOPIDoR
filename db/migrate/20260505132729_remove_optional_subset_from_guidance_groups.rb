class RemoveOptionalSubsetFromGuidanceGroups < ActiveRecord::Migration[8.1]
  def change
    remove_column :guidance_groups, :optional_subset
  end
end
