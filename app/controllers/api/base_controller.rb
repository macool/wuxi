module Api
  class BaseController < ::ApplicationController
    before_action :authenticate_client!

    protected

    def authenticate_client!
      authorization = request.headers['X-Wuxi-Authorization']
      token = authorization.split("token:").last
      api_client = Api::Client.where(token: token).first
      if api_client.present?
        @current_api_client = api_client
      else
        return render(
          nothing: true,
          status: :unauthorized
        )
      end
    end
  end
end
