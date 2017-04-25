formSelector = ".edit_admin_user"
selector = "#{formSelector} #admin_user_role"

$(document).on "change", selector, (e) ->
  $(e.target).parents(formSelector).submit()
