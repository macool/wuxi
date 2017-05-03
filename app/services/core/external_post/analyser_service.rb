module Core
  class ExternalPost
    class AnalyserService
      def initialize(external_post)
        @external_post = external_post
      end

      def analyse!
        @external_post.update!(status: :analysed)
        whitelist = @external_post.external_user.status.whitelist?
        repost_all = @external_post.external_provider.repost.all?
        if whitelist || repost_all || location_whitelisted? || sentiment_analysis.positive?
          # reposting handled by the speaker
          @external_post.update!(status: :will_repost)
          sentiment_analysis.positive? # trigger analysis just in case
        end
      end

      private

      def location_whitelisted?
        LocationAnalyserService.new(
          external_post: @external_post
        ).whitelist?
      end

      def sentiment_analysis
        @sentiment_analysis ||= SentimentAnalyserService.new(
          external_post: @external_post
        ).analyse!
      end
    end
  end
end
