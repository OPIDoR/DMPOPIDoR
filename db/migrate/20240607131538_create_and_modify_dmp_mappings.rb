class CreateAndModifyDmpMappings < ActiveRecord::Migration[7.1]
    def change
      # Supprimez la table si elle existe déjà pour éviter des conflits
      drop_table :dmp_mappings if ActiveRecord::Base.connection.table_exists?('dmp_mappings')
  
      create_table :dmp_mappings do |t|
        t.column :type_mapping, :integer, default: 0
        t.references :source, foreign_key: { to_table: :templates }
        t.references :target, foreign_key: { to_table: :templates }
        t.json :mapping
        t.string :name
  
        t.timestamps
      end
    end
  end
  