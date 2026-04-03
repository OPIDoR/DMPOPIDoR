class AddContextsToTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :templates, :contexts, :string, array: true, null: false, default: ['research_project']
  end
end
