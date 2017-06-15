module Core
  class ExternalUserPolicy < ::ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    def blacklist?
      is_admin?
    end

    def whitelist?
      is_admin?
    end

    def update_status?
      is_admin?
    end

    def analyse_latest_posts?
      is_superadmin?
    end

    def search?
      is_admin?
    end
  end
end
