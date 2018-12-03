# frozen_string_literal: true

# Migration(s) for datasets
class DatasetsMigration < ActiveRecord::Migration
  def up
    create_table :datasets do |t|
      t.string :name
      t.integer :order
      t.text :description
      t.boolean :is_default, default: false
      t.belongs_to :plan, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_reference :answers, :dataset, index: true, foreign_key: true
  end

  def down
    remove_foreign_key :answers, :datasets
    remove_reference :answers, :dataset

    drop_table :datasets
  end
end

namespace :datasets do
  # Migrates the database to use datasets
  # - Adds a dataset table to the base (via the above migrations)
  # - Creates a default dataset for every plan
  # - Moves all plans' answers to their new default dataset
  desc 'Migrate the database to use datasets'
  task enable: :environment do
    # Apply migration
    DatasetsMigration.new.up

    # Create datasets and move answers
    Plan.all.each do |p|
      dataset = p.datasets.create(is_default: true) if p.datasets.empty?
      p.answers.each { |a| a.update_column(:dataset_id, dataset.id) }
    end
  end

  # Rollback for the database migration enable the datasets
  # - Remove all non default datasets and their answers
  # - "Detach" remaining answers from their datasets (the default ones)
  # - Drop the datasets table and reverse the migrations
  desc 'Migrate the database to remove datasets'
  task disable: :environment do
    # Destroy all datasets which are not defaut datasets and their answers
    Dataset.where(is_default: false).destroy_all

    # Rollback migration
    DatasetsMigration.new.down
  end
end
