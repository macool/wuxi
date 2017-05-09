module Api
  class ExternalProvidersController < BaseController
    def index
      external_providers = scope.decorate.map(&:api_response_object)
      render json: {
        external_providers: external_providers
      }
    end

    def show
      external_provider = scope.find(params[:id])
                               .decorate
      render json: {
        external_provider: external_provider.api_response_object
      }
    end

    private

    def scope
      Core::ExternalProvider.active
    end
  end
end
