Enums = Apps.Merchant.Enums
logics.transaction = {} unless logics.transaction
scope = logics.transaction


transactionMenus = scope.transactionMenus = [
  display: "khách hàng"
  icon: "pomegranate icon-users-outline"
  app: "merchantOptions"
,
  display: "nhà cung cấp"
  icon: "carrot icon-location-1"
  app: "staffManagement"
]
