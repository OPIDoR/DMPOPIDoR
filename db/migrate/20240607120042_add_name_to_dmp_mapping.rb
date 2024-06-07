class AddNameToDmpMapping < ActiveRecord::Migration[7.1]
  def change
    add_column :dmp_mappings, :name, :string
  end
end
