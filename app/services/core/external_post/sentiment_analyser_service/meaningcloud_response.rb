module Core
  class ExternalPost
    class SentimentAnalyserService
      class MeaningcloudResponse
        def initialize(response)
          @response = response
        end

        # aka 200
        def ok?
          @response["status"]["msg"] == "OK"
        # TODO catching meaningcloud exceptions?
        rescue NoMethodError
          log "meaningcloud response error!"
          Rails.logger.info @response
        end

        def ok_for_reposting?
          if !ok?
            # meaningcloud response was not successful
            # therefore we can not guarantee it
            return false
          end
          score_tag_allowed_for_reposting?
        end

        private

        def log(str)
          Rails.logger.info "#{self.class} #{str}"
        end

        def score_tag_allowed_for_reposting?
          # The possible values are the following:
          # P+: strong positive
          # P: positive
          # NEU: neutral
          # N: negative
          # N+: strong negative
          # NONE: without sentiment
          non_allowed_values = ["N", "N+"]
          score_tag = @response["score_tag"]
          !non_allowed_values.include?(score_tag)
        end
      end
    end
  end
end
