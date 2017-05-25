module PreSpeaker
  class RepostingCandidate
    def initialize(external_post)
      @external_post = external_post
    end

    def schedule_repost!
      if SimilarRepostService.new(@external_post).unique?
        # reposting handled by the speaker
        @external_post.update!(status: :will_repost)
      end
    end

    def whitelist?
      whitelist = @external_post.external_user.status.whitelist?
      whitelist || @external_post.external_provider.repost.all?
    end
  end
end
