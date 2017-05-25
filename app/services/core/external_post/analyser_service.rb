module Core
  class ExternalPost
    class AnalyserService
      def initialize(external_post)
        @external_post = external_post
      end

      def analyse!
        @external_post.update!(status: :analysed)
        if reposting_candidate.whitelist? || location_whitelisted? || sentiment_analysis.positive?
          reposting_candidate.schedule_repost!
          ##
          # also trigger analysis just in case
          # - would be better to trigger if reposting_candidate
          # is still a candidate (after analysing prev reposts)
          sentiment_analysis.positive?
        end
      end

      private

      def reposting_candidate
        @reposting_candidate ||= PreSpeaker::RepostingCandidate.new(@external_post)
      end

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
