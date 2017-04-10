module Core
  class ExternalProviderDecorator < ::ApplicationDecorator
    decorates_association :posts

    def latest_posts(status)
      object.posts.with_status(status).latest.limit(100).decorate
    end
  end
end
