module Speaker
  class AdPost < PostSchedulerResource
    class SchedulerService
      class << self
        def schedule!
          active_external_providers.each do |external_provider|
            scope = ad_posts_scope_for(external_provider)
            scope.each_with_index do |ad_post, index|
              interval = (13 * index).minutes
              ::AdPostsSpeakerWorker.perform_in(
                interval,
                ad_post.id,
                external_provider.id
              )
            end
          end
        end

        def active_external_providers
          ActiveExternalProvidersFetcher.new.external_providers
        end

        def ad_posts_scope_for(external_provider)
          AdPost.for_external_provider(external_provider)
        end
      end
    end
  end
end
