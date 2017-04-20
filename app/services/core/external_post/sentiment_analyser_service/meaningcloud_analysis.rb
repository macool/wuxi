module Core
  class ExternalPost
    class SentimentAnalyserService
      class MeaningcloudAnalysis
        def initialize(external_post)
          @external_post = external_post
        end

        def perform!
          response = post_to_api
          @meaningcloud_resp = MeaningcloudResponse.new(response.parsed_response)
          if @meaningcloud_resp.ok?
            Brain::ExternalAnalysis.create!(
              subject: @external_post,
              provider: :meaningcloud,
              response: response
            )
          end
          self
        end

        def ok_for_reposting?
          @meaningcloud_resp.ok_for_reposting?
        end

        def post_to_api
          meaningcloud_api.sentiment(
            text: @external_post.raw_hash["text"],
            lang: @external_post.raw_hash["lang"]
          )
        end

        private

        def meaningcloud_api
          MeaningcloudApi.new
        end
      end
    end
  end
end
