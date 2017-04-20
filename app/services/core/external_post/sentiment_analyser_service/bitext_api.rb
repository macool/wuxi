module Core
  class ExternalPost
    class SentimentAnalyserService
      class BitextApi
        include HTTParty
        base_uri "https://svc02.api.bitext.com"
        debug_output

        # Available languages:
        # "eng": English
        # "cat": Catalan
        # "deu": German
        # "fra": French
        # "ita": Italian
        # "nld": Dutch
        # "por": Portuguese
        # "spa": Spanish
        BITEXT_LANGUAGES = {
          en: "eng",
          ca: "cat",
          de: "deu",
          fr: "fra",
          it: "ita",
          nl: "nld",
          po: "por",
          es: "spa"
        }.with_indifferent_access

        def post_sentiment(text:, our_language:)
          language = get_language(our_language)
          self.class.post(
            "/sentiment",
            body: { text: text, language: language }.to_json,
            headers: headers
          )
        end

        def get_sentiment(result_id:)
          fail "define :result_id!" if result_id.blank?
          self.class.get(
            "/sentiment/#{result_id}",
            headers: headers
          )
        end

        private

        def headers
          {
            "Authorization" => "bearer #{token}",
            "Content-Type" => "application/json"
          }
        end

        def get_language(language)
          ##
          # TODO
          # define default language at external provider / account level
          default_language = BITEXT_LANGUAGES[:es]
          BITEXT_LANGUAGES.fetch(language) { default_language }
        end

        def token
          Rails.application.secrets.bitext_token.presence || fail("please define bitext token!")
        end
      end
    end
  end
end
