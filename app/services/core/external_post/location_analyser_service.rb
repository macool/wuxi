module Core
  class ExternalPost
    class LocationAnalyserService
      def initialize(external_post:)
        @external_post = external_post
        @external_user = @external_post.external_user
      end

      def whitelist?
        !any_non_allowed_location? && any_allowed_location?
      end

      private

      def regexp_for(rule)
        /#{rule.content}/i
      end

      def external_post_place_matches?(rule)
        place = external_post_place
        place.present? && place =~ regexp_for(rule)
      end

      def external_user_place_matches?(rule)
        place = @external_user.raw_hash["location"]
        place.present? && place =~ regexp_for(rule)
      end

      def external_post_place
        place = @external_post.raw_hash["place"]
        place && place["full_name"]
      end

      def any_non_allowed_location?
        any_rule_matches?(rules.non_allowed)
      end

      def any_allowed_location?
        any_rule_matches?(rules.allowed)
      end

      def any_rule_matches?(rules)
        rules.any? do |rule|
          external_post_place_matches?(rule) || external_user_place_matches?(rule)
        end
      end

      def rules
        account.rules.location
      end

      def account
        @external_post.external_provider.account
      end
    end
  end
end
