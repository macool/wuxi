class ExternalPostUndoRepostWorker
  include Sidekiq::Worker

  def perform(external_post_id, admin_user_id)
    external_post = Core::ExternalPost.find(external_post_id)
    admin_user = Admin::User.find(admin_user_id)
    Core::ExternalPost::UndoRepostService.new(
      admin_user: admin_user,
      external_post: external_post
    ).perform!
  end
end
