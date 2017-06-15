module Admin
  class UserPolicy < ::ApplicationPolicy
    def manage?
      is_superadmin?
    end
  end
end
