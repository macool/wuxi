module Speaker
  class ActiveExternalProvidersFetcher
    def external_providers
      Core::ExternalProvider.active
                            .for_reposting
                            .with_provider(:twitter)
    end
  end
end
