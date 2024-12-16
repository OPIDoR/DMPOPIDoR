class DropRegistryValues < ActiveRecord::Migration[7.2]
  def change
    drop_table(:registry_values) if table_exists?(:registry_values)
  end
end
