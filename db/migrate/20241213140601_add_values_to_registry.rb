class AddValuesToRegistry < ActiveRecord::Migration[7.2]
  def change
    add_column :registries, :values, :json
  end
end
