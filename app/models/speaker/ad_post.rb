module Speaker
  class AdPost < PostSchedulerResource
    self.element_name = "post"

    def self.for_external_provider(external_provider)
      where(external_provider_id: external_provider.id.to_s)
    end
  end
end
