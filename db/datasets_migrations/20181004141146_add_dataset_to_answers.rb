class AddDatasetToAnswers < ActiveRecord::Migration
  def up
    add_reference :answers, :dataset, index: true, foreign_key: true
  end

  def down
    remove_foreign_key :answers, :datasets
    remove_reference :answers, :dataset
  end
end
