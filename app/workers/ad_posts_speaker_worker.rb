class AdPostsSpeakerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false # scheduled

  def perform(ad_post_id, external_provider_id)
    ad_post = Speaker::AdPost.find ad_post_id
    external_provider = Core::ExternalProvider.find external_provider_id
    Speaker::AdPost::SpeakerService.new(
      ad_post: ad_post,
      external_provider: external_provider
    ).speak!
  end
end
