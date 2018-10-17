# frozen_string_literal: true

require Rails.root.join('db/datasets_migrations/20181004140130_create_datasets.rb')
require Rails.root.join('db/datasets_migrations/20181004141146_add_dataset_to_answers.rb')

namespace :datasets do
  # Migrates the database to use datasets
  # Does:
  # - Adds a dataset table to the base (via the above migrations)
  # - Create a default dataset for every plan
  # - Move all plans' answers to their new default dataset
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
end
