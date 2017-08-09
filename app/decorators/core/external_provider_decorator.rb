module Core
  class ExternalProviderDecorator < ::ApplicationDecorator
    decorates_association :posts

    def latest_posts(status)
      object.posts
            .includes(:external_user)
            .with_status(status)
            .last_reposted
            .page(h.params[:page])
    end

    def place
      object.account.place
    end

    def api_response_object
      {
        id: object.id.to_s,
        nickname: nickname,
        place: place,
        active_for_api: active_for_api
      }
    end
  end
end
