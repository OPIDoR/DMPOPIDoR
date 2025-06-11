class RemoveUnusedTables < ActiveRecord::Migration[7.2]
  def change
    remove_reference :research_outputs, :license
    remove_reference :orgs, :region

    drop_table(:research_domains) if table_exists?(:research_domains)
    drop_table(:licenses) if table_exists?(:licenses)
    drop_table(:metadata_standards) if table_exists?(:metadata_standards)
    drop_table(:repositories) if table_exists?(:repositories)
    drop_table(:regions) if table_exists?(:regions)
    drop_table(:trackers) if table_exists?(:trackers)
  end
end
