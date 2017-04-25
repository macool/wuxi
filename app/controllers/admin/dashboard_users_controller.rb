module Admin
  class DashboardUsersController < BaseController
    before_action :find_admin_user,
                  only: [:show, :update]

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
            user_nickname: @admin_user.nickname
          }
        )
        flash[:notice] = "yey updated!"
      else
        flash[:error] = "ups! something went wrong"
      end
      redirect_to action: :show, id: @admin_user.id
    end

    private

    def admin_user_params
      params.require(:admin_user).permit :role
    end

    def find_admin_user
      @admin_user = Admin::User.find(params[:id])
    end
  end
end
