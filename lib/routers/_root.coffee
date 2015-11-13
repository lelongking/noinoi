Wings.Routers = {}
Wings.SubsManager = new SubsManager({cacheLimit: 9999, expireIn: 9999})

FlowRouter.notFound =
  subscriptions: ->
  action: ->
    BlazeLayout.render 'notFound'

if Meteor.isClient
  BlazeLayout.setRoot('body')

  # Only login in one browser
  Accounts.onLogin (user) ->
    #Todo: xem lai ??? 1 browser mo hai tab van bi
#    # logout other clients
#    Meteor.logoutOtherClients()
#    Session.set 'loggedIn', true

    redirect = Session.get 'redirectAfterLogin'
    if redirect?
      unless redirect is '/login'
        FlowRouter.go redirect

#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
publicRouter = Wings.Routers.rootRouter =
  FlowRouter.group
    name: "public"
    triggersEnter: [ (context, redirect, stop) ->
      if Meteor.userId()
        redirect '/merchant'
        stop()
      return
    ]

publicRouter.route '/',
  name: 'home'
  action: ->
    BlazeLayout.render 'about'
    return
  triggersEnter: [ (context, redirect) ->
    console.log Meteor.user()
    console.log 'running /admin trigger'
    return
  ]

publicRouter.route '/register',
  name: 'register'
  action: ->
    BlazeLayout.render 'homeLayout'

publicRouter.route '/login',
  name: 'login'
  action: (params, queryParams)->
    if queryParams.version is 'login_v01'
      BlazeLayout.render 'login_v01'
    else
      BlazeLayout.render 'notFound'
  triggersEnter: [ (context, redirect, stop) ->
    unless context.queryParams.version
      BlazeLayout.render 'login_v01'
      stop()
  ]


#-------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------
loggedInRouter = Wings.Routers.loggedInRouter =
  FlowRouter.group
    name: "loggedIn"
    triggersEnter: [ (context, redirect, stop) ->
      unless Meteor.loggingIn() or Meteor.userId()
        route = FlowRouter.current()
        unless route.route.name is 'login'
          Session.set 'redirectAfterLogin', route.path
        redirect '/login'
        stop()
      return
    ]

loggedInRouter.route '/lockScreen',
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

loggedInRouter.route '/merchant',
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