class AddKcUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :kc_uid, :string
  end
end
