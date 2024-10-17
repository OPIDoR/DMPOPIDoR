class RemoveLocaleAndAddTranslationsInTheme < ActiveRecord::Migration[7.1]
  def change
    remove_column :themes, :locale, :string
    add_column :themes, :translations, :json, default: {}
  end
end
