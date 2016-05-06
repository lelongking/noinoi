merchantRouter = Wings.Routers.merchantRouter =
  Wings.Routers.loggedInRouter.group
    prefix: '/merchant'
    name: "merchant"
    triggersEnter: [ (context, redirect, stop) ->
      $(".tooltip").remove()
      Helpers.arrangeAppLayout()
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

merchantRouter.route '/login',
  name: 'login'
  action: (params, queryParams)->
    BlazeLayout.render 'login_v01'

  triggersEnter: [ (context, redirect, stop) ->
  #    unless context.queryParams.version
  #      BlazeLayout.render 'lockScreen_v1'

    if Meteor.userId()
      redirect '/merchant'
      console.log 'login'
      stop()
  ]

merchantRouter.route '/register',
  name: 'register'
  action: ->
    Session.set "currentAppInfo",
      name: "đăng ký"

    BlazeLayout.render 'homeLayout'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /register trigger'
    unless Meteor.userId()
      redirect '/merchant/login'
      console.log 'login'
      stop()
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




#------------------------------------------------------------------------------------
metroHome = setups.metroHome = {}

metroHome.customerApp =
  appName      : 'customer'
  appCount     : 'customers'
  appColor     : 'lime'
  appSize      : 'quatro'
  appClass     : 'customer-management overlay'
  appIcon      : ''

  description  : ''
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

  description  : ''
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

  description  : ''
  caption      : 'sản phẩm'
  captionClass : 'bottom right'

  isCanvas     : true
  canvasClass  : ''



metroHome.transactionApp =
  appName      : 'transaction'
  appColor     : 'orange'
  appCount     : ''
  appSize      : 'double'
  appClass     : ''
  appIcon      : ''

  description  : 'thu chi'
  caption      : 'Tài Chính'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.interestRateApp =
  appName      : 'interestRate'
  appColor     : 'emeral'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'lãi suất'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.orderApp =
  appName      : 'order'
  appColor     : 'amethyst'
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
  appColor     : 'peter-river'
  appCount     : 'billManagers'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'tình trạng'
  caption      : 'giao hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.importApp =
  appName      : 'import'
  appColor     : 'turquoise'
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
  appColor     : 'wet-asphalt'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'kho hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.priceBookApp =
  appName      : 'priceBook'
  appColor     : 'carrot'
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
  appColor     : 'concrete'
  appCount     : 'staffs'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'nhân sự'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.merchantOptionsApp =
  appName      : 'option'
  appColor     : 'wet-asphalt'
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
  appName      : 'orderReturn'
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

metroHome.logsApp =
  appName      : ''
  appColor     : 'concrete'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'hoạt động'
  caption      : 'nhật ký'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.providerReturnApp =
  appName      : 'importReturn'
  appColor     : 'yellow'
  appCount     : 'providerReturnHistories'
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : 'phiếu'
  caption      : 'trả hàng'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.reportApp =
  appName      : 'report'
  appColor     : 'lime'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'Báo Cáo'
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

  description  : ''
  caption      : 'Báo Cáo'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''



metroHome.programManagerApp =
  appName      : ''
  appColor     : 'pink'
  appCount     : ''
  appSize      : ''
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'Mùa Vụ'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''
metroHome.basicReportApp =
  appName      : 'basicReport'
  appColor     : 'magenta'
  appCount     : 'revenueDay'
  appSize      : 'double'
  appClass     : ''
  appIcon      : ''

  description  : ''
  caption      : 'thống kê'
  captionClass : 'bottom right'

  isCanvas     : false
  canvasClass  : ''

metroHome.statisticApp =
  appName      : 'statistic'
  appColor     : 'teal'
  appCount     : 'revenueDay'
  appSize      : 'double'
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
    setups.metroHome.priceBookApp
  ,
    setups.metroHome.programManagerApp
  ]
,
  classGroup: 'tile-group-2'
  dataGroup: [
    setups.metroHome.interestRateApp
  ,
    setups.metroHome.merchantOptionsApp
  ,
    setups.metroHome.customerReturnApp
  ,
    setups.metroHome.staffManagementApp
  ,
    setups.metroHome.providerReturnApp
  ,
    setups.metroHome.reportApp
  ,
    setups.metroHome.statisticApp
  ]
]