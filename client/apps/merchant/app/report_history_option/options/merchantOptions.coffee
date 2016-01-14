scope = logics.merchantOptions





Wings.defineAppContainer 'merchantOptions',
  created: ->
    self = this
    self.autorun ()->
      if Session.get("myProfile")
        scope.myProfile = Session.get("myProfile")
        if !Session.get("merchantOptionsCurrentDynamics") and settings.system
          Session.set "merchantOptionsCurrentDynamics", settings.system[0]

  rendered: ->

  destroyed: ->
    Wings.Helper.ResetSession([
      'merchantOptionsCurrentDynamics'
    ])

  helpers:
    settings: -> settings
    currentSectionDynamic: -> Session.get("merchantOptionsCurrentDynamics")
    optionActiveClass: -> if @template is Session.get("merchantOptionsCurrentDynamics")?.template then 'active' else ''

  events:
    "click .caption.inner": -> Session.set("merchantOptionsCurrentDynamics", @)


settings = {}

settings.account = [
  display: "thông tin"
  icon: "icon-vcard"
  template: "merchantAccountOverview"
  data: Session.get("myProfile")
,
  display: "mật khẩu"
  icon: "icon-key-outline"
  template: "merchantAccountChangePassword"
  data: Session.get("myProfile")
]

settings.merchant = [
  display: "cửa hàng"
  icon: "icon-home-4"
  template: "merchantInfoOptions"
  data: Session.get("merchant")
,
  display: "kho hàng"
  icon: "icon-cubes"
  template: "warehouseInfoOptions"
  data: Session.get("myProfile")
]

settings.system = [
  display: "tùy chỉnh"
  icon: "icon-tools"
  template: "merchantSystemOptions"
  data: Session.get("myProfile")
,
  display: "ghi chú"
  icon: "icon-edit"
  template: "merchantNoteOptions"
  data: Session.get("myProfile")

#,
#  display: "ngôn ngữ"
#  icon: "icon-location-1"
#  template: "merchantLanguageOptions"
#  data: undefined
#,
#  display: "trò chuyện"
#  icon: "icon-chat-6"
#  template: "merchantMessengerOptions"
#  data: undefined
#,
#  display: "nhắc nhở"
#  icon: "icon-bell"
#  template: "merchantNotificationOptions"
#  data: undefined
]

settings.printing = [
  display: "mẫu in"
  icon: "blue icon-clipboard"
  template: "merchantPrintDesigner"
  data: undefined
]

settings.apps = [
#    display: "bán hàng - giao hàng"
#    icon: "orange icon-tags"
#    template: "merchantSaleOptions"
#    data: undefined
#  ,
#    display: "kho - nhập kho"
#    icon: "green-sea icon-download-outline"
#    template: "merchantImportOptions"
#    data: undefined
#  ,
#    display: "khách hàng"
#    icon: "lime icon-contacts"
#    template: "merchantCustomerOptions"
#    data: undefined
#  ,
#    display: "nhà cung cấp"
#    icon: "carrot icon-anchor-outline"
#    template: "merchantProviderOptions"
#    data: undefined
]

settings.staff = [
  display: "nhân sự"
  icon: "icon-group"
  template: "merchantStaffOptions"
  data: Session.get("myProfile")
,
  display: "phân quyền"
  icon: "icon-group"
  template: "merchantHROptions"
  data: Session.get("myProfile")
]
