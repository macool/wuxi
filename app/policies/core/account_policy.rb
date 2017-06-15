module Core
  class AccountPolicy < ::ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    def edit?
      is_superadmin?
    end

    def new?
      is_superadmin?
    end

    def create?
      is_superadmin?
    end

    def update?
      is_superadmin?
    end
  end
end
