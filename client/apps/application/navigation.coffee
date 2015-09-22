@navigationMenus = [
  description: 'Tin tức tự động'
  color: 'pumpkin'
  icon: 'icon-appbar-home-gps'
  app: "news"
,
#  description: 'Notification'
#  color: 'blue'
#  icon: 'icon-comment'
#  app: "notification"
#,
  description: 'Kế hoạch'
  color: 'nephritis'
  icon: 'icon-appbar-projector-screen'
  app: "plan"
,
  description: 'Nhân sự'
  color: 'purple'
  icon: 'icon-appbar-group'
  app: "user"
,
  description: 'Khách hàng'
  color: 'lime'
  icon: 'icon-appbar-people'
  app: "customer"
,
  description: 'Bán hàng'
  color: 'sun-flower'
  icon: 'icon-appbar-page-corner-bookmark'
  app: "order"
,
  description: 'Sản phẩm'
  color: 'carrot'
  icon: 'icon-appbar-resource-group'
  app: "product"
,
  description: 'Nhập kho'
  color: 'teal'
  icon: 'icon-appbar-social-dropbox'
  app: "import"
,
  description: 'Kế toán'
  color: 'blue'
  icon: 'icon-appbar-cogs'
  app: "system"
]

Template.navigation.helpers
  currentDescription: -> Session.get("currentAppDescription")
  currentColor: -> Session.get("temporaryAppColor") ? Session.get("currentAppColor")
  addonMenus: -> navigationMenus
  activeClass: -> if Session.get("currentAddon") is @app then 'active' else ''
  connectionStatus: -> Meteor.status().status

Template.navigation.events
  "click .addon-launcher": (event, template) -> Wings.go @app
  "click .app-descriptions": -> Session.set "kernelAddonVisible", !Session.get("kernelAddonVisible")
  "click .navigator.home": (event, template) -> Wings.go(Router.current().params.sub)
  "click .navigator.backward": (event, template) -> history.back()
  "click .navigator.forward": (event, template) -> history.forward()
  "mouseenter .addon-launcher": (event, template) ->
    Session.set "currentAppDescription", $(event.currentTarget).attr('description')
    Session.set "temporaryAppColor", @color
  "mouseleave .addon-launcher": (event, template) ->
    Session.set "currentAppDescription"
    Session.set "temporaryAppColor"
  "mouseenter .navigator": (event, template) -> Session.set "currentAppDescription", $(event.currentTarget).attr('description')
  "mouseleave .navigator": (event, template) -> Session.set "currentAppDescription"