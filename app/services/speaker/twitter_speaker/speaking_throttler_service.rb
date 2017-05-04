module Speaker
  class TwitterSpeaker
    class SpeakingThrottlerService
      THROTTLER = {
        "1000" => 4,
        "500"  => 3,
        "100"  => 2,
        "0"    => 1
      }

      def initialize(scope:)
        @scope = scope
      end

      def throttling_limit
        mark, speed = THROTTLER.detect do |queue_size, value|
          @scope.count >= queue_size.to_i
        end
        speed
      end
    end
  end
end
