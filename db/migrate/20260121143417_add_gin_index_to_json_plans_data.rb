class AddGinIndexToJsonPlansData < ActiveRecord::Migration[8.1]
  def change
    add_index :json_plans, :data, using: :gin, name: 'idx_json_plans_data_gin'
  end
end
