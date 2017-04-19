module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextResponse
        delegate :body, :parsed_response, to: :@response

        def initialize(response)
          @response = response
        end

        def failed?
          @response.response.is_a?(Net::HTTPServiceUnavailable)
        end

        def result_id
          @response["resultid"]
        end

        def ok_for_reposting?
          scores = @response["sentimentanalysis"].map do |analysis|
            analysis["score"].to_f
          end
          avg_score = scores.sum / scores.length
          avg_score > 0
        end

        def ok?
          @response.response.is_a?(Net::HTTPOK)
        end
      end
    end
  end
end
