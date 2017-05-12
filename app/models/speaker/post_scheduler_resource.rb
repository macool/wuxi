module Speaker
  class PostSchedulerResource < ActiveResource::Base
    self.site = Rails.application.secrets.post_scheduler_api_url
    token = Rails.application.secrets.post_scheduler_api_token
    self.headers['X-Wuxi-Authorization'] = "Bearer token:#{token}"
  end
end
