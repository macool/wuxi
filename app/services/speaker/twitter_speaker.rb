module Speaker
  class TwitterSpeaker
    class << self
      def speak!
        active_external_providers.each do |external_provider|
          scope = external_posts_scope_for(external_provider)
          throttler_limit = throttler_limit_for(scope)
          scope.limit(throttler_limit).each do |external_post|
            new(external_post).speak!
          end
        end
      end

      def active_external_providers
        ActiveExternalProvidersFetcher.new
                                      .external_providers
                                      .for_reposting
      end

      def external_posts_scope_for(external_provider)
        external_provider.posts
                         .latest
                         .with_status(:will_repost)
      end

      def throttler_limit_for(scope)
        SpeakingThrottlerService.new(
          scope: scope
        ).throttling_limit
      end
    end

    def initialize(external_post)
      @external_post = external_post
    end

    def speak!
      retweet!
      @external_post.reposted!
    end

    private

    def retweet!
      twitter_client.retweet!(
        Twitter::Tweet.new(
          @external_post.raw_hash.with_indifferent_access
        )
      )
    rescue Exception => e
      TwitterSpeakingException.new(
        exception: e,
        external_post: @external_post
      ).handle!
    end

    def twitter_client
      Core::ExternalProvider::TwitterClientService.from_external_provider(
        @external_post.external_provider
      ).twitter_client
    end
  end
end
