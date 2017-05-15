module Speaker
  class ActiveExternalProvidersFetcher
    def external_providers
      Core::ExternalProvider.active
                            .with_provider(:twitter)
    end
  end
end
