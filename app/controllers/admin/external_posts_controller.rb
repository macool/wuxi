module Admin
  class ExternalPostsController < BaseController
    before_action :set_action_name

    def repost
      scope = Core::ExternalPost.with_status(:new, :analysed)
      @external_post = scope.find(params[:id])
      @external_post.update!(
        status: :will_repost,
        manually_reposted: true
      )
      generic_response
    end

    def cancel_repost
      scope = Core::ExternalPost.with_status(:will_repost)
      @external_post = scope.find(params[:id])
      @external_post.update!(
        status: :analysed,
        manually_reposted: false
      )
      generic_response
    end

    private

    def set_action_name
      @action_name = params[:action]
    end

    def generic_response
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render :update_external_post_status }
      end
    end
  end
end
