module Admin
  class DashboardUsersController < BaseController
    def index
      @role = params[:role] || 'user'
      @admin_users = Admin::User.with_role(@role)
    end

    def show
      @admin_user = Admin::User.find(params[:id])
      @admin_user = @admin_user.decorate
      @role = @admin_user.role
    end
  end
end
