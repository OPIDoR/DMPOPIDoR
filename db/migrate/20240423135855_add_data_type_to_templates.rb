class AddDataTypeToTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :templates, :data_type, :string, null: false, default: 'none'
  end
end
