module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    # after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:alert] = I18n.t("pundit.not_authorized")
      redirect_to(request.referrer || root_path)
    end
  end
end
