selector = ".top.menu .toggle-main-menu"
mainPusherSelector = "#main-pusher"
$mainSidebar = null

$(document).on "click", "#{selector}", ->
  $mainSidebar = $("#main-sidebar")
  $mainSidebar.toggleClass("visible")

  isVisible = $mainSidebar.hasClass("visible")
  if isVisible
    setPusherListener()

setPusherListener = ->
  $mainPusher = $(mainPusherSelector)
  $mainPusher.on "click", ->
    $mainPusher.off "click"
    $mainSidebar.toggleClass("visible")
