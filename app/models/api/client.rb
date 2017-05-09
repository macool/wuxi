module Api
  class Client
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String
    field :token, type: String

    index({ token: 1 }, { unique: true })

    validates :token,
              presence: true,
              uniqueness: true
  end
end
