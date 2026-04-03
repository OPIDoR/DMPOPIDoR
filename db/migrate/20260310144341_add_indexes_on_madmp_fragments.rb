class AddIndexesOnMadmpFragments < ActiveRecord::Migration[8.1]
  def change
    add_index :madmp_fragments, "(data->>'plan_id')", 
              name: 'madmp_fragments_plan_id_idx',
              using: :btree
    add_index :madmp_fragments, "(data->>'research_output_id')", 
              name: 'madmp_fragments_research_output_id_idx',
              using: :btree
    add_index :madmp_fragments, :dmp_id, 
              name: 'madmp_fragments_dmp_id_idx',
              using: :btree
    add_index :madmp_fragments, :parent_id, 
              name: 'madmp_fragments_parent_id_idx',
              using: :btree
  end
end
