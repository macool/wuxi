module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextResponse
        delegate :body, :parsed_response, to: :@response

        def initialize(response)
          @response = response
        end

        def failed?
          failed = @response.response.is_a?(Net::HTTPServiceUnavailable)
          failed = failed || @response["success"] == false
          if failed
            log "WARN: #failed?: true! response.body: #{@response.body}"
          end
          failed
        end

        def result_id
          @response["resultid"]
        end

        def ok_for_reposting?
          if @response["sentimentanalysis"].blank?
            ##
            # TODO remove debugging
            log "WARN: #ok_for_reposting? response.body: #{@response.body}"
          end
          scores = @response["sentimentanalysis"].map do |analysis|
            analysis["score"].to_f
          end
          avg_score = scores.sum / scores.length
          avg_score > 0
        end

        def ok?
          @response.response.is_a?(Net::HTTPOK)
        end

        def incomplete?
          @response["status"] == "incomplete"
        end

        private

        def log(str)
          Rails.logger.info "[#{self.class}] #{str}"
        end
      end
    end
  end
end
