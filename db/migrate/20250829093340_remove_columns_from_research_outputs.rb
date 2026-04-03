class RemoveColumnsFromResearchOutputs < ActiveRecord::Migration[8.0]
  def change
    remove_column :research_outputs, :byte_size
    remove_column :research_outputs, :personal_data
    remove_column :research_outputs, :release_date
    remove_column :research_outputs, :sensitive_data
    remove_column :research_outputs, :access
  end
end
