# frozen_string_literal: true

# TODO: improve to source all migrations from the dir and execute in order (reversed to down)
require Rails.root.join('db/datasets_migrations/20181004140130_create_datasets.rb')
require Rails.root.join('db/datasets_migrations/20181004141146_add_dataset_to_answers.rb')

namespace :datasets do
  # Migrates the database to use datasets
  # - Adds a dataset table to the base (via the above migrations)
  # - Creates a default dataset for every plan
  # - Moves all plans' answers to their new default dataset
  desc 'Migrate the database to use datasets'
  task enable: :environment do
    CreateDatasets.new.up # Create Dataset table
    AddDatasetToAnswers.new.up # Adds Dataset <-> Answer foreign key

    # Create datasets and move answers
    Plan.all.each do |plan|
      plan.datasets.create(is_default: true) unless plan.has_datasets?
      Answer.where(plan_id: plan.id).each do |answer|
        answer.update_column(:dataset_id, plan.default_dataset.id)
      end
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

    AddDatasetToAnswers.new.down # Remove Dataset <-> Answer foreign key
    CreateDatasets.new.down # Remove dataset table
  end
end
