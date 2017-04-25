module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextResponse
        KNOWN_ERRORS = [
          "Free request limit reached.",
          "No contract found for that language",
          "Contract expired"
        ].freeze

        delegate :body, :parsed_response, to: :@response

        def initialize(response)
          @response = response
        end

        def failed?
          failed = @response.response.is_a?(Net::HTTPServiceUnavailable)
          failed = failed || @response["success"] == false
          if failed && unkown_error?
            log "WARN: #failed?: true! response.body: #{@response.body}"
            log "WARN: #failed?: true! response.request: #{@response.request.raw_body}"
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

          # if no results
          return true if scores.length == 0

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

        def unkown_error?
          KNOWN_ERRORS.none? do |error_message|
            matches = @response["message"] == error_message
            if matches
              log("[bitext-error]: #{error_message} [lang]: #{@response.request.raw_body['language']}")
            end
            matches
          end
        end

        def log(str)
          Rails.logger.info "[#{self.class}] #{str}"
        end
      end
    end
  end
end
