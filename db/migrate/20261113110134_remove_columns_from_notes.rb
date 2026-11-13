class RemoveColumnsFromNotes < ActiveRecord::Migration[8.1]
  def change
    remove_column :notes, :archived
    remove_column :notes, :archived_by
  end
end
