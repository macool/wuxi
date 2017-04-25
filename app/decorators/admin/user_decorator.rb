module Admin
  class UserDecorator < ::ApplicationDecorator
    def link_to_profile(&block)
      h.link_to profile_uri,
                target: "_blank" do
        yield
      end
    end

    def recent_from_activity(page)
      Core::Activity.latest
                    .from_user(object)
                    .page(page)
                    .per(10)
    end

    def recent_to_activity(page)
      Core::Activity.latest
                    .for_subject(object)
                    .page(page)
                    .per(10)
    end

    def full_image
      info["image"].gsub(/_normal/, "")
    end

    private

    def profile_uri
      case provider
      when "twitter"
        "http://twitter.com/#{object.nickname}"
      end
    end
  end
end
