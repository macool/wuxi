class AdPostsSchedulerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false # scheduled

  def perform
    Speaker::AdPost::SchedulerService.schedule!
  end
end
