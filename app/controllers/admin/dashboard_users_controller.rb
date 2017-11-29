module Admin
  class DashboardUsersController < BaseController
    before_action :pundit_authorize
    before_action :find_admin_user, only: [:show, :update]
    before_action :restrict_self_user, only: :update

    def index
      @role = params[:role] || 'user'
      @admin_users = Admin::User.with_role(@role)
    end

    def show
      @admin_user = @admin_user.decorate
      @role = @admin_user.role
    end

    def update
      if @admin_user.update(admin_user_params)
        ##
        # log_activity!
        Core::Activity.create!(
          subject: @admin_user,
          whodunit_id: current_user.id,
          action: :admin_user_role_update,
          predicate: {
            params: admin_user_params,
            target_admin_user: @admin_user.nickname
          }
        )
        flash[:notice] = "yey updated!"
      else
        flash[:error] = "ups! something went wrong"
      end
      redirect_to action: :show, id: @admin_user.id
    end

    private

    def restrict_self_user
      if @admin_user == current_user
        flash[:error] = I18n.t("actions.cant_update_self_user")
        redirect_to :back
      end
    end

    def pundit_authorize
      authorize Admin::User, :manage?
    end

    def admin_user_params
      params.require(:admin_user).permit :role
    end

    def find_admin_user
      @admin_user = Admin::User.find(params[:id])
    end
  end
end
