class AddPdfDataToPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :plans, :pdf_data, :binary
  end
end
