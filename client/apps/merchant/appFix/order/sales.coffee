Enums = Apps.Merchant.Enums
scope = logics.sales

Wings.defineApp 'order',
  created: ->
    UnitProductSearch.search('')
    Session.setDefault('globalBarcodeInput', '')
    Session.setDefault('allowCreateOrderDetail', false)
    Session.setDefault('allowSuccessOrder', false)
    self = this
    self.autorun ()->
      if Session.get('mySession')
        scope.currentOrder = Schema.orders.findOne({
          _id        : Session.get('mySession').currentOrder
          orderType  : Enums.getValue('OrderTypes', 'initialize')
          orderStatus: Enums.getValue('OrderStatus', 'initialize')
        })
        Session.set 'currentOrder', scope.currentOrder

      if newBuyerId = Session.get('currentOrder')?.buyer
        if !(oldBuyerId = Session.get('currentBuyer')?._id) or oldBuyerId isnt newBuyerId
          Session.set('currentBuyer', Schema.customers.findOne newBuyerId)
      else
        Session.set 'currentBuyer'


  rendered: ->
    scope.templateInstance = @
    $(document).on "keypress", (e) -> scope.handleGlobalBarcodeInput(e)



  destroyed: ->
    $(document).off("keypress")


  helpers:
    currentOrder: -> Session.get('currentOrder')
    productTextSearch: -> ProductSaleSearch?.getCurrentQuery() ? ''
    allowCreateOrderDetail: -> if !scope.currentProduct then 'disabled'
    allowSuccessOrder: -> if Session.get('allowSuccess') then '' else 'disabled'
    avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined

    tabOptions: -> scope.tabOptions
    customerSelectOptions: -> scope.customerSelectOptions
    paymentMethodSelectOption: -> scope.paymentMethodSelectOptions
    paymentsDeliverySelectOption: -> scope.paymentsDeliverySelectOptions

    debtDateOptions: -> scope.debtDateOptions
    discountOptions: -> scope.discountOptions
    depositOptions: -> scope.depositOptions



  events:
    "click .print-command": (event, template) -> window.print()
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    "click .addSaleDetail": ->
      scope.currentOrder.addDetail(@_id); event.stopPropagation()

    "click .finish": (event, template)->
      scope.currentOrder.orderConfirm()

    "click .export-command": (event, template) ->
      link = window.document.createElement('a')
      link.setAttribute 'href', '/download/order/' + Session.get("currentOrder")._id
      link.click()

#      dataArray = []; customer = Session.get("currentBuyer")
#      headOrder    = ['Sản Phẩm', 'ĐVT', 'Thùng', 'Chai/Goi', '']
#      headCustomer = ['Khách Hàng', 'Số ĐT', 'Địa Chỉ', 'Số Phiếu']
#      headColumns = headOrder.concat(headCustomer)
#      dataArray[index] = [head] for head, index in headColumns
#
#      orderDataLength = 1
#      if currentOrder = Session.get("currentOrder")
#        for detail in currentOrder.details
#          orderDataLength += 1
#          if product = Schema.products.findOne(detail.product)
#            unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0
#
#            array = [
#              product.name
#              product.unitName()
#              unitQuantity
#              detail.basicQuantity
#            ]
#            dataArray[index].push(array[index] ? '') for head, index in headOrder
#
#
#      customerBillNo = Helpers.orderCodeCreate(Session.get('currentBuyer')?.saleBillNo ? '00')
#      merchantBillNo = Helpers.orderCodeCreate(Session.get('merchant')?.saleBillNo ? '00')
#      customerData = [
#        customer?.name
#        customer?.profiles?.phone
#        customer?.profiles?.address
#        customerBillNo + '/' + merchantBillNo
#      ]
#      dataArray[index+headOrder.length].push(customerData[index] ? '') for head, index in headCustomer
#      maxLength = 2
#      maxLength = orderDataLength if orderDataLength > maxLength
#
#      link = window.document.createElement('a')
#      link.setAttribute 'href', 'data:text/csv;charset=utf-8,' + encodeURI(Helpers.JSON2CSV(dataArray, maxLength))
#      link.setAttribute 'download', 'xuat_kho.csv'
#      link.click()