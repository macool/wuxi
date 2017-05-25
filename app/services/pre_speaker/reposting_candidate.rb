module PreSpeaker
  class RepostingCandidate
    def initialize(external_post)
      @external_post = external_post
    end

    def schedule_repost!
      similar_repost_service = SimilarRepostService.new(@external_post)
      if similar_repost_service.unique?
        # reposting handled by the speaker
        @external_post.update!(status: :will_repost)
      else
        @external_post.update!(status: :halted_by_similarity_analyser)
        Core::Activity.create!(
          subject: @external_post,
          action: :external_post_pre_speaker_similarity,
          predicate: { similar_content: similar_repost_service.similar_content }
        )
      end
    end

    def whitelist?
      whitelist = @external_post.external_user.status.whitelist?
      whitelist || @external_post.external_provider.repost.all?
    end
  end
end
