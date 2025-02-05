class AddDataTypeToRegistriesThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :registries, :data_types, :string, array: true, null: false, default: ['none']
    add_column :themes, :data_type, :string, null: false, default: 'none'
  end
end
