module Core
  class BannedWordPolicy < ::ApplicationPolicy
    def manage?
      is_admin?
    end
  end
end
