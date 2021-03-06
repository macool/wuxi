module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextAnalysis
        def initialize(external_post)
          @external_post = external_post
        end

        ##
        # dance with bitext api
        # first a POST to analyse
        # then a GET for the result - which may not be
        # complete yet so may need to retry
        def perform!
          post_response = perform_post_request
          if bitext_halted? || post_response.failed?
            @post_failed = true
          else
            @get_response = perform_get_request(post_response)
            if @get_response.ok?
              Brain::ExternalAnalysis.create!(
                subject: @external_post,
                provider: :bitext,
                response: @get_response.parsed_response
              )
            end
          end
          self
        end

        def ok_for_reposting?
          ##
          # we can't rely on bitext
          # if server is 2 busy or something we'll say
          # it's okay
          @post_failed || @get_response.ok_for_reposting?
        end

        private

        def bitext_halted?
          Rails.cache.read(BitextResponse::HALT_CACHE_KEY)
        end

        def perform_get_request(post_response)
          return if bitext_halted?
          if post_response.result_id.blank?
            # TODO catching bitext exceptions?
            Rails.logger.info "#{self.class} bitext post response without result_id!"
            Rails.logger.info post_response
          end
          response = bitext_api.get_sentiment(
            result_id: post_response.result_id
          )
          response = BitextResponse.new(response)
          tries = 1
          # TODO: this actually falls into an infinite loop
          # http://pangi.shiriculapo.com/apps/57166044a2462b05eb00007e/problems/59be2c710a1e1a0c01000043
          # if response.incomplete? && tries < 10
          #   # let's wait for the api for 3s before querying
          #   # again
          #   sleep 3
          #   tries += 1
          #   response = perform_get_request(post_response)
          # end
          response
        end

        def perform_post_request
          response = bitext_api.post_sentiment(
            text: @external_post.raw_hash["text"],
            our_language: @external_post.raw_hash["lang"]
          )
          return BitextResponse.new(response)
        rescue Net::ReadTimeout => e
          Rails.logger.info "#{self.class} [error] bitext timed out!"
          return BitextResponse.new(e)
        end

        def bitext_api
          @bitext_api ||= BitextApi.new
        end

        def log(str)
          Rails.logger.info "[#{self.class}] #{str}"
        end
      end
    end
  end
end
