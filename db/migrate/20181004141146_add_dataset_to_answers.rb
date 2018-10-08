class AddDatasetToAnswers < ActiveRecord::Migration
  def change
    add_reference :answers, :dataset, index: true, foreign_key: true
  end
end
