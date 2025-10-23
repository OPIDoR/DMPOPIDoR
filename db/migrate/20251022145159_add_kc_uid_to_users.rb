class AddKcUidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :kc_uid, :string
  end
end
