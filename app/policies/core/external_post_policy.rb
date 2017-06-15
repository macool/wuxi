module Core
  class ExternalPostPolicy < ::ApplicationPolicy
    def repost?
      is_superadmin?
    end

    def cancel_repost?
      is_admin?
    end

    def trash_bin?
      is_admin?
    end
  end
end
