module Admin
  class ExternalUsersController < BaseController
    before_action :pundit_authorize
    before_action :find_external_user,
                  only: [
                    :show,
                    :update_status,
                    :analyse_latest_posts
                  ]

    def index
      @status = params[:status]
      scope = Core::ExternalUser
      if @status.present?
        scope = scope.with_status(@status)
      end
      if params[:query].present?
        search_regexp = /^#{params[:query]}/i
        scope = scope.or(
          :"raw_hash.name" => search_regexp
        ).or(
          :"raw_hash.screen_name" => search_regexp
        )
      end
      @external_users = scope.page(params[:page])
    end

    def show
      @external_user = @external_user.decorate
      @status = @external_user.status
    end

    def update_status
      Core::ExternalUser::StatusUpdaterService.new(
        params: params,
        current_user: current_user,
        external_user: @external_user
      ).update!
      respond_to do |format|
        format.js
        format.html {
          redirect_to action: :show, id: @external_user.id
        }
      end
    end

    def analyse_latest_posts
      Core::ExternalUser::LatestPostsAnalyserService.new(
        current_user: current_user,
        external_user: @external_user
      ).schedule_analysis!
      respond_to do |format|
        format.js
        format.html {
          redirect_to action: :show, id: @external_user.id
        }
      end
    end

    private

    def pundit_authorize
      authorize Core::ExternalUser
    end

    def find_external_user
      @external_user = Core::ExternalUser.find params[:id]
    rescue Mongoid::Errors::DocumentNotFound
      @external_user = Core::ExternalUser.by_screen_name params[:id]
    end
  end
end
