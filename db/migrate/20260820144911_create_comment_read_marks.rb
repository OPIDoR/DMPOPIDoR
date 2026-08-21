class CreateCommentReadMarks < ActiveRecord::Migration[8.1]
  def change
    create_table :comment_read_marks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true
      t.timestamp :last_read_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
