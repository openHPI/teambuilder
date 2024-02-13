class GroupingWorker
  include Sidekiq::Job
  sidekiq_options retry: 0 # Skip retries, send a failed job straight to the Dead set

  def perform(course_id, enabled_features, opts, team_settings)
    # In Redis, the symbol keys are transformed into strings so we have to undo
    # that process here.
    Course.find(course_id).group_teams!(
      enabled_features,
      opts.symbolize_keys,
      team_settings.symbolize_keys
    )
  end
end
