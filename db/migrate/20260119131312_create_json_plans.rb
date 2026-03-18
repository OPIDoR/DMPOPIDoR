class CreateJsonPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :json_plans do |t|
      t.references :plan, null: false, foreign_key: true
      t.string :dmp_id
      t.string :research_outputs_uuids, array: true, default: []
      t.jsonb :data

      t.timestamps
    end

    add_index :json_plans, :dmp_id
  end
end
