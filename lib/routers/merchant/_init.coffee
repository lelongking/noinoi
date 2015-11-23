merchantRouter = Wings.Routers.merchantRouter =
  Wings.Routers.loggedInRouter.group
    prefix: '/merchant'
    name: "merchant"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
#        FlowRouter.go FlowRouter.path('dashboard')
#        stop()
    ]

merchantRouter.route '/',
  name: 'metro'
  action: ->
    Session.set "currentAppInfo", name: "trung tâm"

    BlazeLayout.render 'merchantLayout',
      content: 'merchantHome'
      contentData: setups.metroHome.metroData

    return
  triggersEnter: [ (context, redirect) ->
    console.log 'running /metro trigger'
    return
  ]

merchantRouter.route '/lockScreen',
  name: 'lockScreen'
  action: (params, queryParams)->
    if queryParams.version is 'lockScreen_v1'
      BlazeLayout.render 'lockScreen_v1'
    else
      BlazeLayout.render 'notFound'

  triggersEnter: [ (context, redirect, stop) ->
    unless context.queryParams.version
      BlazeLayout.render 'lockScreen_v1'
      stop()
  ]


merchantRouter.route '/basicHistory',
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"
      navigationPartial:
        template: "basicHistoryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'basicHistory'
    return

  triggersEnter: [ (context, redirect, stop) ->
    return
  ]


#-------------------------------------------------------------------------------------------------------------------
FlowRouter.route '/billDetail',
  name: 'billDetail'
  action: ->
    Session.set "currentAppInfo",
      name: "chi tiết phiếu bán"

    BlazeLayout.render 'merchantLayout',
      content: 'billDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/basicHistory',
  name: 'basicHistory'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"
      navigationPartial:
        template: "basicHistoryNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'basicHistory'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/billManager',
  name: 'billManager'
  action: ->
    Session.set "currentAppInfo",
      name: "tình trạng phiếu bán"

    BlazeLayout.render 'merchantLayout',
      content: 'billManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/customer',
  name: 'customer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'customerManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

FlowRouter.route '/customer/:customerId',
  name: 'customerId'
  triggersEnter: [ (context, redirect) ->
    console.log 'running /customer trigger'
    return
  ]

  action: (params, queryParams) ->
    console.log params, queryParams

    Session.set "currentAppInfo",
      name: "khách hàng"
      navigationPartial:
        template: "customerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'customerManagement'
    return



FlowRouter.route '/customerGroup',
  name: 'customerGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm khách hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'customerGroup'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]





FlowRouter.route '/returnCustomer',
  name: 'returnCustomer'
  action: ->
    Session.set "currentAppInfo",
      name: "khách hàng trả hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'customerReturn'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/import',
  name: 'import'
  action: ->
    Session.set "currentAppInfo",
      name: "nhập kho"

    BlazeLayout.render 'merchantLayout',
      content: 'import'
    return

  triggersEnter: [ (context, redirect) ->
    FlowRouter.go('/merchant') unless User.hasManagerRoles()
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/option',
  name: 'option'
  action: ->
    Session.set "currentAppInfo",
      name: "tuỳ chỉnh"

    BlazeLayout.render 'merchantLayout',
      content: 'merchantOptions'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/order',
  name: 'order'
  action: ->
    Session.set "currentAppInfo",
      name: "bán hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'order'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/orderManager',
  name: 'orderManager'
  action: ->
    Session.set "currentAppInfo",
      name: "đơn hàng"

    BlazeLayout.render 'merchantLayout',
      content: 'orderManager'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/priceBook',
  name: 'priceBook'
  action: ->
    Session.set "currentAppInfo",
      name: "bảng giá"

    BlazeLayout.render 'merchantLayout',
      content: 'priceBook'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/product',
  name: 'product'
  action: ->
    Session.set "currentAppInfo",
      name: "sản phầm"
      navigationPartial:
        template: "productManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'productManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/productGroup',
  name: 'productGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm sản phẩm"

    BlazeLayout.render 'merchantLayout',
      content: 'productGroup'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/provider',
  name: 'provider'
  action: ->
    Session.set "currentAppInfo",
      name: "nhà cung cấp"
      navigationPartial:
        template: "providerManagementNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'providerManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/returnProvider',
  name: 'returnProvider'
  action: ->
    Session.set "currentAppInfo",
      name: "trả hàng NCC"

    BlazeLayout.render 'merchantLayout',
      content: 'providerReturn'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

FlowRouter.route '/basicReport',
  name: 'basicReport'
  action: ->
    Session.set "currentAppInfo",
      name: "báo cáo"

    BlazeLayout.render 'merchantLayout',
      content: 'basicReport'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /basicReport trigger'
    return
  ]


FlowRouter.route '/staff',
  name: 'staff'
  action: ->
    Session.set "currentAppInfo",
      name: "nhân viên"

    BlazeLayout.render 'merchantLayout',
      content: 'staffManagement'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/transaction',
  name: 'transaction'
  action: ->
    Session.set "currentAppInfo",
      name: "thu chi - tài chính"
      navigationPartial:
        template: "transactionNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'transaction'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]


FlowRouter.route '/warehouse',
  name: 'warehouse'
  action: ->
    Session.set "currentAppInfo",
      name: "quản lý kho hàng"
      navigationPartial:
        template: "warehouseNavigationPartial"
        data: {}

    BlazeLayout.render 'merchantLayout',
      content: 'warehouse'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]
#

#FlowRouter.route '/saleProgram',
#  name: 'customerGroup'
#  action: ->
#    Session.set "currentAppInfo",
#      name: "nhóm khách hàng"
#
#    BlazeLayout.render 'merchantLayout',
#      content: 'customerGroup'
#    return
#
#  triggersEnter: [ (context, redirect) ->
#    console.log 'running /provider trigger'
#    return
#  ]



#------------------------------------------------------------------------------------
metroHome = setups.metroHome = {}

metroHome.customerApp =
  appName      : 'customer'
  appCount     : 'customers'
  appColor     : 'lime'
  appSize      : 'quatro'
  appClass     : 'customer-management overlay'
  appIcon      : ''

  description  : 'tất cả'
  caption      : 'khách hàng'
  captionClass : 'bottom right'

  isCanvas     : true
  canvasClass  : 'double'

metroHome.providerApp =
  appName      : 'provider'
  appColor     : 'pumpkin'
  appCount     : 'providers'
  appSize      : 'double'
  appClass     : 'distributor-management overlay'
  appIcon      : ''

  description  : 'tất cả'
  caption      : 'nhà cung cấp'
  captionClass : 'bottom right'

  isCanvas     : true
  canvasClass  : ''

metroHome.productApp =
  appName      : 'product'
  appColor     : 'belize-hole'
  appCount     : 'products'
  appSize      : 'double'
  appClass     : 'product-management overlay'
  appIcon      : ''

  description  : 'tất cả'
  caption      : 'sản phẩm'
  captionClass : 'bottom right'

  isCanvas     : true
  canvasClass  : ''



metroHome.customerGroupApp =
  appName      : 'customerGroup'
  appColor     : 'green-sea'
  appCount     : 'customerGroups'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'NHÓM'
  caption      : 'khách hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.transactionApp =
  appName      : 'transaction'
  appColor     : 'alizarin'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'thu chi'
  caption      : 'Tài Chính'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.orderApp =
  appName      : 'order'
  appColor     : 'wet-asphalt'
  appCount     : 'orders'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'phiếu'
  caption      : 'bán hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.billManagerApp =
  appName      : 'billManager'
  appColor     : 'lime'
  appCount     : 'billManagers'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'tình trạng'
  caption      : 'phiếu bán'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.importApp =
  appName      : 'import'
  appColor     : 'carrot'
  appCount     : 'imports'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'phiếu'
  caption      : 'nhập kho'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.warehouseApp =
  appName      : 'warehouse'
  appColor     : 'peter-river'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'kho hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.productGroupApp =
  appName      : 'productGroup'
  appColor     : 'amethyst'
  appCount     : 'productGroups'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'NHÓM'
  caption      : 'sản phẩm'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.priceBookApp =
  appName      : 'priceBook'
  appColor     : 'light-green'
  appCount     : 'priceBooks'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'bảng giá'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''




metroHome.staffManagementApp =
  appName      : 'staff'
  appColor     : 'emeral'
  appCount     : 'staffs'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'nhân viên'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.merchantOptionsApp =
  appName      : 'option'
  appColor     : 'dark-blue'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'hệ thống'
  caption      : 'tùy chỉnh'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.customerReturnApp =
  appName      : 'returnCustomer'
  appColor     : 'pink'
  appCount     : 'customerReturnHistories'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'khách hàng'
  caption      : 'trả hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.orderManagerApp =
  appName      : 'orderManager'
  appColor     : 'wisteria'
  appCount     : 'orderManagers'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'hoàn thành'
  caption      : 'phiếu bán'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.providerReturnApp =
  appName      : 'returnProvider'
  appColor     : 'pumpkin'
  appCount     : 'providerReturnHistories'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'phiếu'
  caption      : 'trả hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.basicHistoryApp =
  appName      : 'basicHistory'
  appColor     : 'orange'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'Báo Cáo'
  caption      : 'nhật ký'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.programManagerApp =
  appName      : 'saleProgram'
  appColor     : 'peter-river'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'Chương Trình'
  caption      : 'Bán Hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.basicReportApp =
  appName      : 'basicReport'
  appColor     : 'magenta'
  appCount     : 'revenueDay'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'thống kê'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''




setups.metroHome.metroData = [
  classGroup: 'tile-group-2'
  dataGroup: [
    setups.metroHome.customerApp
  ,
    setups.metroHome.providerApp
  ,
    setups.metroHome.productApp
  ]
,
  classGroup: 'tile-group-2'
  dataGroup: [
    setups.metroHome.customerGroupApp
  ,
    setups.metroHome.transactionApp
  ,
    setups.metroHome.orderApp
  ,
    setups.metroHome.billManagerApp
  ,
    setups.metroHome.importApp
  ,
    setups.metroHome.warehouseApp
  ,
    setups.metroHome.productGroupApp
  ,
    setups.metroHome.priceBookApp
  ]
,
  classGroup: 'tile-group-2'
  dataGroup: [
    setups.metroHome.staffManagementApp
  ,
    setups.metroHome.merchantOptionsApp
  ,
    setups.metroHome.customerReturnApp
  ,
    setups.metroHome.orderManagerApp
  ,
    setups.metroHome.providerReturnApp
  ,
    setups.metroHome.basicHistoryApp
  ,
    setups.metroHome.programManagerApp
  ,
    setups.metroHome.basicReportApp
  ]
]