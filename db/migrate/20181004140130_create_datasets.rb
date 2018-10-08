class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name
      t.integer :order
      t.text :description
      t.boolean :is_default, default: false
      t.belongs_to :plan, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
