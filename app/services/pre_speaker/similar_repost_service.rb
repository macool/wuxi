module PreSpeaker
  class SimilarRepostService
    QUEUE_SIZE = 300

    attr_reader :similar_content

    def initialize(external_post)
      @external_post = external_post
    end

    def unique?
      ##
      # comparing against similar recent posts
      # by this external provider
      unique = recent_posts.none? do |content|
        similar = white_similar_to?(content) && small_distance_to?(content)
        if similar
          @similar_content = content
        end
        similar
      end
      if unique
        push_to_recent_posts_queue!
      end
      unique
    end

    private

    def external_provider_redis_key
      "#{self.class.to_s.underscore}:#{@external_post.external_provider.id.to_s}"
    end

    def recent_posts
      return Sidekiq.redis do |redis|
        return redis.lrange(external_provider_redis_key, 0, -1)
      end
    end

    def push_to_recent_posts_queue!
      Sidekiq.redis do |redis|
        redis.lpush(external_provider_redis_key, stripped_content)
        redis.ltrim(external_provider_redis_key, 0, QUEUE_SIZE)
      end
    end

    def stripped_content
      @stripped_content ||= @external_post.raw_hash["text"].gsub(
        /(?:f|ht)tps?:\/[^\s]+/,
        ''
      )
    end

    def white_similar_to?(content)
      @white_similarity ||= Text::WhiteSimilarity.new
      similarity = @white_similarity.similarity(
        content,
        stripped_content
      )
      similarity > 0.5
    end

    def small_distance_to?(content)
      max_distance = 10
      distance = Text::Levenshtein.distance(
        content,
        stripped_content,
        max_distance
      )
      distance < max_distance
    end
  end
end
