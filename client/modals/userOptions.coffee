optionMenus = [
  display: "Notifications"
  template: "notificationOptions"
,
  display: "Hồ sơ"
  template: "profileOptions"
,
  display: "Trình bày"
  template: "displayOptions"
,
  display: "Nâng cao"
  template: "advanceOptions"
]

Wings.defineModal "modalUserOptions",
  helpers:
    optionMenus: optionMenus
    detailTemplate: -> Session.get("userOptionActiveMenu")
    activeMenuClass: -> if @template is Session.get("userOptionActiveMenu") then 'active' else ''

  events:
    "click .option-menu": (event, template) -> Session.set("userOptionActiveMenu", @template)