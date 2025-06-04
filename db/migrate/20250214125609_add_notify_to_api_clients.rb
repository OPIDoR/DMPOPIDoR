class AddNotifyToApiClients < ActiveRecord::Migration[7.2]
  def change
    add_column :api_clients, :notify, :boolean, default: false, null: false
  end
end
