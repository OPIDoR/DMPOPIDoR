class JsonPlanJobScheduler
  class << self
    def enqueue_or_reschedule(plan_id, delay = 600)
      args = [{ plan_id: plan_id }]

      delay_seconds = ENV.fetch('PLANS_ACTIVE_JOB_DELAY', delay).to_i # in seconds

      existing_job = GoodJob::Job.where("serialized_params->'arguments' @> ?", args.to_json)
                                 .where(finished_at: nil)
                                 .first


      if existing_job
        existing_job.update!(scheduled_at: delay_seconds.seconds.from_now)
      else
        JsonPlanJob.set(wait: delay_seconds.seconds).perform_later(plan_id: plan_id)
      end
    end
  end
end
