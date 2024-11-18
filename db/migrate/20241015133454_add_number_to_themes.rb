class AddNumberToThemes < ActiveRecord::Migration[7.1]
  def change
    add_column :themes, :number, :integer
  end
end
