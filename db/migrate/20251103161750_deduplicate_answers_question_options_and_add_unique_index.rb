class DeduplicateAnswersQuestionOptionsAndAddUniqueIndex < ActiveRecord::Migration[8.0]
  def up
    # Supprimer les doublons en gardant la première occurrence
    execute <<-SQL
      DELETE FROM answers_question_options aqo
      WHERE aqo.ctid NOT IN (
        SELECT MIN(aqo2.ctid)
        FROM answers_question_options aqo2
        GROUP BY aqo2.question_option_id, aqo2.answer_id
      )
    SQL

    # Ajouter un index unique pour éviter les doublons futurs
    add_index :answers_question_options, [:question_option_id, :answer_id], unique: true
  end

  def down
    # Supprimer l’index unique si on revient en arrière
    remove_index :answers_question_options, column: [:question_option_id, :answer_id]
  end
end
