module Core
  class ExternalPost
    class UndoRepostService
      def initialize(external_post:, admin_user:)
        @admin_user = admin_user
        @external_post = external_post
      end

      def perform!
        log_activity!
        undo_retweet!
        @external_post.update!(status: :trash_binned)
      end

      private

      def log_activity!
        Activity.create!(
          subject: @external_post,
          whodunit_id: @admin_user.id,
          action: :admin_user_undo_repost
        )
      end

      def undo_retweet!
        twitter_client.unretweet(@external_post.uid)
      end

      def twitter_client
        Core::ExternalProvider::TwitterClientService.from_external_provider(
          @external_post.external_provider
        ).twitter_client
      end
    end
  end
end
