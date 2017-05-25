module Core
  class ExternalProvider
    extend Enumerize
    include Mongoid::Document
    include Mongoid::Timestamps

    SUPPORTED_PROVIDERS = {
      twitter: "https://twitter.com"
    }.with_indifferent_access.freeze
    PROVIDERS = SUPPORTED_PROVIDERS.keys.map(&:to_s).freeze

    field :active, type: Boolean, default: false
    field :search_active, type: Boolean, default: false
    field :active_for_api, type: Boolean, default: false
    field :repost, type: String
    field :provider, type: String
    field :uid, type: String
    field :info, type: Hash
    field :credentials, type: Hash

    index({ active: 1 })

    validate :provider_is_unique
    validates :account,
              :provider,
              :uid,
              presence: true

    enumerize :provider,
              in: [:twitter],
              scope: true
    enumerize :repost,
              in: [:none, :all, :whitelist],
              scope: true,
              default: :none

    begin :relationships
      belongs_to :account,
                 class_name: "Core::Account"
      has_many :posts,
               class_name: "Core::ExternalPost"
    end

    scope :active, ->{ where(active: true) }
    scope :active_for_api, ->{ active.where(active_for_api: true) }
    scope :search_active, -> { where(search_active: true) }
    scope :for_reposting, ->{ with_repost(:all, :whitelist) }

    def external_uri
      case provider
      when "twitter"
        SUPPORTED_PROVIDERS[:twitter] + "/" + info["screen_name"]
      end
    end

    def nickname
      case provider
      when "twitter"
        "@" + info["screen_name"]
      end
    end

    def to_s
      nickname
    end

    private

    def provider_is_unique
      existing_scope = self.class.where(uid: uid, provider: provider)
      existing_scope = existing_scope.where(:id.ne => id) unless new_record?

      if existing_scope.exists?
        existing_provider = existing_scope.first
        errors.add(
          :base,
          "Ya está asociada a la cuenta #{existing_provider.account.name}"
        )
      end
    end
  end
end
