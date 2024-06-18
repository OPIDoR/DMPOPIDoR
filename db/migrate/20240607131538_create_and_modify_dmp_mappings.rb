class CreateTableTemplateMappings < ActiveRecord::Migration[7.1]
    def change
      create_table :template_mappings do |t|
        t.column :type_mapping, :integer, default: 0
        t.references :source, foreign_key: { to_table: :templates }
        t.references :target, foreign_key: { to_table: :templates }
        t.json :mapping
        t.string :name
  
        t.timestamps
      end
    end
  end
  