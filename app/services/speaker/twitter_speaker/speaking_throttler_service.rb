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
        @scope_size = scope.count
      end

      def throttling_limit
        mark, speed = THROTTLER.detect do |queue_size, value|
          @scope_size >= queue_size.to_i
        end
        speed
      end
    end
  end
end
