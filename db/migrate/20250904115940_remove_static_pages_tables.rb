class RemoveStaticPagesTables < ActiveRecord::Migration[8.0]
  def change
    drop_table(:static_page_contents) if table_exists?(:static_page_contents)
    drop_table(:static_pages) if table_exists?(:static_pages)
  end
end
