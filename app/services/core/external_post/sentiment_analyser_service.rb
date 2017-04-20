module Core
  class ExternalPost
    class SentimentAnalyserService
      def initialize(external_post:)
        @external_post = external_post
      end

      def analyse!
        schedule_sentiment140_analysis!
        self
      end

      def positive?
        analysers_answers = [
          analyse_with_bitext!
        ]
        if @external_post.external_user.status.whitelist?
          # premium analysis?
          analysers_answers << analyse_with_meaningcloud!
        end
        analysers_answers.all?
      end

      private

      def schedule_sentiment140_analysis!
        # analysis is handled in BG
        Brain::ScheduledAnalysis.create!(
          subject: @external_post,
          lang: @external_post.raw_hash["lang"]
        )
      end

      def analyse_with_bitext!
        BitextAnalysis.new(
          @external_post
        ).perform!
         .ok_for_reposting?
      end

      def analyse_with_meaningcloud!
        MeaningcloudAnalysis.new(
          @external_post
        ).perform!
         .ok_for_reposting?
      end

      def log(str)
        Rails.logger.info "[#{self.class}] #{str}"
      end
    end
  end
end
