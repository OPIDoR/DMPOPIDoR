class AddContextToPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :plans, :context, :integer, null: false, default: 0
  end
end
