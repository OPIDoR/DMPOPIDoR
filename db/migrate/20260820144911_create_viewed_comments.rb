class CreateViewedComments < ActiveRecord::Migration[8.1]
  def change
    create_table :viewed_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true
      t.timestamp :last_read_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :viewed_comments, [:user_id, :answer_id], unique: true
  end
end
