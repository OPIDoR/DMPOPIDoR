class AddClassnameToRegistries < ActiveRecord::Migration[7.2]
  def change
    add_column :registries, :classname, :string
  end
end
