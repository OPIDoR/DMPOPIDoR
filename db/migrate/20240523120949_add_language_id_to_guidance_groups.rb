class AddLanguageIdToGuidanceGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :guidance_groups, :language_id, :integer, default: 0
  end
end
