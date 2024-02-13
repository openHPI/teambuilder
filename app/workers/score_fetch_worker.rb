class ScoreFetchWorker
  include Sidekiq::Job

  def perform(course_id)
    Course.find(course_id).update_scores!
  end
end
