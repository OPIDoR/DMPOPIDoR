# frozen_string_literal: true

namespace :datasets do
  desc 'Migrate the database to use datasets'
  task enable: :environment do
    Plan.all.each do |plan|
      plan.datasets.create(is_default: true) unless plan.has_datasets?
      Answer.where(plan: plan).each do |answer|
        answer.update_column(:dataset_id, plan.default_dataset.id)
      end
    end
    ActiveRecord::Base.record_timestamps = true
  end
end
