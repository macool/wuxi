module Speaker
  class AdPost < PostSchedulerResource
    class SpeakerService
      def initialize(ad_post:, external_provider:)
        @ad_post = ad_post
        @external_provider = external_provider
      end

      def speak!
        tweet = publish_to_twitter!
        @ad_post.update_attributes(
          published: true,
          tweet_id: tweet.id.to_s
        )
      end

      private

      def publish_to_twitter!
        twitter_client.update!(
          @ad_post.repost_content
        )
      end

      def twitter_client
        Core::ExternalProvider::TwitterClientService.from_external_provider(
          @external_provider
        ).twitter_client
      end
    end
  end
end
