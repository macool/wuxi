module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextResponse
        KNOWN_ERRORS = [
          "Free request limit reached.",
          "No contract found for that language",
          "Contract expired"
        ].freeze
        KNOWN_EXCEPTIONS = [
          Net::ReadTimeout
        ].freeze
        HALT_CACHE_KEY = "bitext_analysis_halted".freeze

        delegate :body, :parsed_response, to: :@response

        def initialize(response)
          @response = response
        end

        def failed?
          failed = @response.is_a?(Net::ReadTimeout)
          failed = failed || @response.response.is_a?(Net::HTTPServiceUnavailable)
          failed = failed || (@response["success"] == false)
          if failed && (unkown_exception? || unkown_error?)
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
          @response.response.is_a?(Net::HTTPOK) && !incomplete?
        end

        def incomplete?
          @response["status"] == "incomplete"
        end

        private

        def unkown_error?
          KNOWN_ERRORS.none? do |error_message|
            matches = @response["message"] == error_message
            if matches
              handle_known_error(error_message)
              raw_body = @response.request.raw_body
              language = raw_body[raw_body.index("language")..(raw_body.size - 1)]
              log("[bitext-error]: #{error_message} [lang]: #{language}")
            end
            matches
          end
        end

        def unkown_exception?
          KNOWN_EXCEPTIONS.none? do |exception_class|
            matches = @response.is_a?(exception_class)
            if matches
              value = exception_class.to_s
              expiration_time = 1.hour
              log("[bitext-error]: #{exception_class} - won't retry for #{expiration_time}")
              halt_bitext_with_cache(value, expiration_time)
            end
            matches
          end
        end

        def handle_known_error(kind)
          case kind
          when "Free request limit reached."
            expiration_time = 12.hours
          when "Contract expired"
            expiration_time = 1.day
          else
            return
          end
          halt_bitext_with_cache(kind, expiration_time)
        end

        def halt_bitext_with_cache(value, expiration_time)
          Rails.cache.write(
            HALT_CACHE_KEY,
            value,
            expires_in: expiration_time
          )
        end

        def log(str)
          Rails.logger.info "[#{self.class}] #{str}"
        end
      end
    end
  end
end
