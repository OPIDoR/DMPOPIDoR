class AddCategoryToRegistries < ActiveRecord::Migration[7.2]
  def change
    add_column :registries, :category, :string
  end
end
