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
        bitext_api = BitextApi.new
        post_response = bitext_api.post_sentiment(
          text: @external_post.raw_hash["text"],
          our_language: @external_post.raw_hash["lang"]
        )
        post_response = BitextResponse.new(post_response)
        if post_response.failed?
          ##
          # we can't rely on bitext
          # if server is 2 busy or something we'll say it's okay
          log "bitext POST failed. Response: #{post_response.body}"
          return true
        end
        get_response = bitext_api.get_sentiment(post_response.result_id)
        get_response = BitextResponse.new(get_response)
        if get_response.ok?
          Brain::ExternalAnalysis.create!(
            subject: @external_post,
            provider: :bitext,
            response: get_response.parsed_response
          )
        end
        get_response.ok_for_reposting?
      end

      def analyse_with_meaningcloud!
        meaningcloud_api = MeaningcloudApi.new
        response = meaningcloud_api.sentiment(
          text: @external_post.raw_hash["text"],
          lang: @external_post.raw_hash["lang"]
        )
        meaningcloud = MeaningcloudResponse.new(response.parsed_response)
        if meaningcloud.ok?
          Brain::ExternalAnalysis.create!(
            subject: @external_post,
            provider: :meaningcloud,
            response: response
          )
        end
        meaningcloud.ok_for_reposting?
      end

      def log(str)
        Rails.logger.info "[#{self.class}] #{str}"
      end
    end
  end
end
