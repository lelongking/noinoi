toggleCollapse = -> Session.set 'collapse', if Session.get('collapse') is 'collapsed' then '' else 'collapsed'
arrangeSideBar = (context) ->
  messengerHeight = $("#messenger").outerHeight()
#  brandingHeight = $(".branding").outerHeight()
  brandingHeight = $(".sidebar-header").outerHeight()*2
  msgListHeight = $(window).height() - brandingHeight - messengerHeight
  $("ul.messenger-list").css("height", "#{msgListHeight}px") if msgListHeight > 150

#  metroWrapperHeight = $(".dual-detail.metro").outerHeight()
#  if metroWrapperHeight > 500
#    metroTopHeight = (metroWrapperHeight - 500)/2
#  else
#    metroTopHeight = 0
#  $(".metro-inner-wrapper").css("top", "#{metroTopHeight}px")

startHomeTracker = ->
  Apps.Merchant.homeTracker = Tracker.autorun ->
    FlowRouter.go('login') if !Meteor.userId()

#    if Session.get("myProfile")
#      merchantProfile = Schema.merchantProfiles.findOne({merchant: Session.get("myProfile").currentMerchant})
#      return if !merchantProfile
#      if !merchantProfile.merchantRegistered
#        if merchantProfile.user is Meteor.userId()
#          FlowRouter.go('/merchantWizard')
#        else
#          FlowRouter.go('/')

destroyHomeTracker = -> Apps.Merchant.homeTracker.stop()

Wings.defineWidget 'merchantLayout',
  helpers:
    collapse: -> Session.get('collapse') ? ''

  created: ->
    Session.set("collapse", 'collapsed')
    startHomeTracker()

  rendered: ->
    arrangeSideBar(@)

    $(window).resize ->
      Helpers.arrangeAppLayout()
      arrangeSideBar(@)
      $(".nano").nanoScroller()

  destroyed: ->
    $(window).off("resize")
    destroyHomeTracker()
  events:
    "click .collapse-toggle": -> toggleCollapse(); Helpers.arrangeAppLayout()