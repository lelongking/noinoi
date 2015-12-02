Wings.defineWidget 'navComponent',
  rendered: -> console.log "rendered"

  helpers:
    currentDescription: -> Session.get("currentAppDescription")
    currentColor: -> Session.get("temporaryAppColor") ? Session.get("currentAppColor")
    addonMenus: -> navigationMenus


  events:
    "mouseenter .addon-launcher": (event, template) ->
      Session.set "currentAppDescription", $(event.currentTarget).attr('description')
      Session.set "temporaryAppColor", @color
    "mouseleave .addon-launcher": (event, template) ->
      Session.set "currentAppDescription"
      Session.set "temporaryAppColor"
      "mouseenter .navigator": (event, template) -> Session.set "currentAppDescription", $(event.currentTarget).attr('description')
      "mouseleave .navigator": (event, template) -> Session.set "currentAppDescription"



navigationMenus = [
  description: 'Tin tức tự động'
  color: 'pumpkin'
  icon: 'icon-off-1'
  app: "news"
,
  description: 'Nhân sự'
  color: 'purple'
  icon: 'icon-off-1'
  app: "user"
,
  description: 'Khách hàng'
  color: 'lime'
  icon: 'icon-off-1'
  app: "customer"
,
  description: 'Bán hàng'
  color: 'sun-flower'
  icon: 'icon-off-1'
  app: "order"
,
  description: 'Sản phẩm'
  color: 'carrot'
  icon: 'icon-off-1'
  app: "product"
]