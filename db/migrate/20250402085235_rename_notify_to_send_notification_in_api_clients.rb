class RenameNotifyToSendNotificationInApiClients < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:api_clients, :notify)
      rename_column :api_clients, :notify, :send_notification
    elsif !column_exists?(:api_clients, :send_notification)
      add_column :api_clients, :send_notification, :boolean, default: false
    end
  end
end
