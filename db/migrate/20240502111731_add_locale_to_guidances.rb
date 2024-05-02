class AddLocaleToGuidances < ActiveRecord::Migration[7.1]
  def change
    add_column :guidances, :locale, :string, default: 'fr-FR'
  end
end
