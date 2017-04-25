module ApplicationHelper
  def active_dashboard_accounts
    Core::Account.all
  end
end
