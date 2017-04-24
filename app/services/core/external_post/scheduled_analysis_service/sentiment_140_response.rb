module Core
  class ExternalPost
    class ScheduledAnalysisService
      class Sentiment140Response
        class TweetInResponse
          delegate :slice, :fetch, to: :@content

          def initialize(content)
            @content = content
          end

          def positive?
            @content["polarity"] == 4 # AKA P+
          end
        end

        def initialize(body)
          @body = body
        end

        def external_posts_response
          JSON.parse(@body)["data"].map do |tweet_content|
            TweetInResponse.new(tweet_content)
          end
        end
      end
    end
  end
end
