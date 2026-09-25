class ChangeDataTypeDefaults < ActiveRecord::Migration[8.1]
  def change
    change_column :guidance_groups, :data_types, :string, array: true, null: false, default: ['dataset']

    change_column :registries, :data_types, :string, array: true, null: false, default: ['dataset']

    change_column :themes, :data_type, :string, null: false, default: 'dataset'

    change_column :templates, :data_type, :string, null: false, default: 'dataset'
    
    change_column :madmp_schemas, :data_type, :string, null: false, default: 'dataset'
  end
end
