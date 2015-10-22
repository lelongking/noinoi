Enums = Apps.Merchant.Enums
Wings.defineApp 'basicHistoryNavigationPartial',
  events:
    "click .showProvider": (event, template) -> Session.set("basicHistoryIsShowCustomer", false)
    "click .showCustomer": (event, template) -> Session.set("basicHistoryIsShowCustomer", true)