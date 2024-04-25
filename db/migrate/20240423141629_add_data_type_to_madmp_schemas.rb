class AddDataTypeToMadmpSchemas < ActiveRecord::Migration[7.1]
  def change
    add_column :madmp_schemas, :data_type, :string, null: false, default: 'none'
  end
end
