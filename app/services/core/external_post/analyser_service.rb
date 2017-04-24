module Core
  class ExternalPost
    class AnalyserService
      def initialize(external_post)
        @external_post = external_post
      end

      def analyse!
        sentiment_analysis = SentimentAnalyserService.new(
          external_post: @external_post
        ).analyse!
        @external_post.update!(status: :analysed)

        whitelist = @external_post.external_user.status.whitelist?
        repost_all = @external_post.external_provider.repost.all?
        if sentiment_analysis.positive? && (whitelist || repost_all)
          # reposting handled by the speaker
          @external_post.update!(status: :will_repost)
        end
      end
    end
  end
end
