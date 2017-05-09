module Api
  class ExternalProvidersController < BaseController
    def index
      json = scope.map do |external_provider|
        {
          id: external_provider.id.to_s,
          nickname: external_provider.nickname,
          place: external_provider.place
        }
      end
      render json: json
    end

    private

    def scope
      Core::ExternalProvider.active.decorate
    end
  end
end
