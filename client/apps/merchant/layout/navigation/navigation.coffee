Wings.defineApp 'navigation',
  created: ->
    self = this
    self.isMerchantHome = new ReactiveVar(false)
    self.autorun ()->
      self.isMerchantHome.set(FlowRouter.current().path is '/merchant')
      self.isMerchantHome.set(FlowRouter.current().path is '/merchant') if FlowRouter.watchPathChange()

  rendered: ->
#    console.log 'navigate rendered'


  helpers:
    isMerchantHome: -> Template.instance().isMerchantHome.get()

    unreadMessageCount: -> logics.merchantNotification.unreadMessages.count()
    unreadNotifiesCount: -> logics.merchantNotification.unreadNotifies.count()
    unreadRequestCount: -> logics.merchantNotification.unreadRequests.count()
    subMenus: -> Session.get('subMenus')
    tourVisible: -> true #Session.get('currentTourName') is ''
    navigationPartial: -> Session.get("currentAppInfo")?.navigationPartial
    appInfo: ->
      return {
        navigationPartial : Session.get("currentAppInfo")?.navigationPartial
        color             : Session.get("currentAppInfo")?.color ? 'white'
      }


  events:
    "click .home": -> FlowRouter.go('/merchant')
    "click #logoutButton": (event, template) -> Wings.logout('login')
    "click #goHomeButton": (event, template) -> FlowRouter.go('/')
#    "click a.branding": -> Session.set('autoNatigateDashboardOff', true); FlowRouter.go('/')
#    "click .tour-toggle": -> Apps.currentTour?.restart()