logics.priceBook = {} unless logics.priceBook
scope = logics.priceBook



scope.getPriceBookPrevious = (search, current) ->
  PriceBookSearch.history[search].data.getPreviousBy('_id', Session.get('mySession').currentPriceBook)
scope.getPriceBookNext     = (search) ->
  PriceBookSearch.history[search].data.getNextBy('_id', Session.get('mySession').currentPriceBook)

scope.searchPriceBookSearchAndCreate = (event, template)->
  searchFilter  = template.ui.$searchFilter.val()
  priceBookSearch = Helpers.Searchify searchFilter
  Session.set("priceBookSearchFilter", searchFilter)

  if event.which is 17 then console.log 'up'
  else if event.which is 38
    PriceBook.setSession(previousRow._id) if previousRow = scope.getPriceBookPrevious(priceBookSearch)
  else if event.which is 40
    PriceBook.setSession(nextRow._id) if nextRow = scope.getPriceBookNext(priceBookSearch)
  else
    scope.createNewPriceBook(template, searchFilter) if event.which is 13
    PriceBookSearch.search priceBookSearch

scope.createNewPriceBook = (template, searchFilter) ->
  if PriceBook.nameIsExisted(searchFilter, Session.get("myProfile").merchant)
    template.ui.$searchFilter.notify("Bảng giá đã tồn tại.", {position: "bottom"})
  else
    newPriceBookId = PriceBook.insert searchFilter
    if Match.test(newPriceBookId, String)
      PriceBook.setSession(newPriceBookId)
      PriceBookSearch.cleanHistory()
      PriceBookSearch.search PriceBookSearch.getCurrentQuery()



scope.findAllProductUnits = (priceBook)->
  productLists = []
  lists = Schema.products.find(
    {_id: {$in: priceBook.products} ,'priceBooks._id': priceBook._id}
    {sort: {name: 1}}
  ).fetch()

  for product in lists
    productPriceBook = _.findWhere(product.priceBooks, {_id: priceBook._id})
    basicUnit = _.findWhere(product.units, {isBase: true})

    if basicUnit and productPriceBook
      product.productName     = product.name
      product.productUnitName = basicUnit.name
      product.priceBookType   = priceBook.priceBookType

      product.basicSale    = productPriceBook.basicSale
      product.salePrice    = productPriceBook.salePrice
      product.saleDiscount = productPriceBook.basicSale - productPriceBook.salePrice

      product.basicImport    = productPriceBook.basicImport
      product.importPrice    = productPriceBook.importPrice
      product.importDiscount = productPriceBook.basicImport - productPriceBook.importPrice

      productLists.push(product)

  scope.allProductUnits = productLists
  return productLists

findPriceBookTypes   = (priceBookTypeId)-> _.findWhere(Apps.Merchant.PriceBookTypes, {_id: priceBookTypeId})
priceBookOwnerSearch  = (query) ->
  if Session.get("currentPriceBook").priceBookType is 0
    [{_id: 0, name: 'TOÀN BỘ'}]
  else if Session.get("currentPriceBook").priceBookType is 1
    Schema.customers.find({}).fetch()
#  else if Session.get("currentPriceBook").priceBookType is 2
#    Schema.customers.find({}).fetch()
  else if Session.get("currentPriceBook").priceBookType is 3
    Schema.providers.find({}).fetch()
#  else if Session.get("currentPriceBook").priceBookType is 4
#    Schema.providers.find({}).fetch()

priceBookOwnerFindOne = (owners)->
  if Session.get("currentPriceBook").priceBookType is 0
    {_id: 0, name: 'TẤT CẢ'}
  else if Session.get("currentPriceBook").priceBookType is 1
    Schema.customers.findOne(owners[0])
#  else if Session.get("currentPriceBook").priceBookType is 2
#    Schema.customers.find({}).fetch()
  else if Session.get("currentPriceBook").priceBookType is 3
    Schema.providers.findOne(owners[0])
#  else if Session.get("currentPriceBook").priceBookType is 4
#    Schema.providers.find({}).fetch()


formatOwnerSearch = (item) -> "#{item.name}" if item
scope.priceBookOwnerSelectOptions =
  query: (query) -> query.callback
    results: priceBookOwnerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback priceBookOwnerFindOne(scope.currentPriceBook.owners)
  formatSelection: formatOwnerSearch
  formatResult: formatOwnerSearch
  id: '_id'
  placeholder: 'CHỌN ĐỐI TƯỢNG ÁP DỤNG'
  changeAction: (e) ->
    scope.currentPriceBook.changeOwner(e.added._id)

  reactiveValueGetter: ->
    if Session.get("currentPriceBook").priceBookType is 0 then {_id: 0, name: 'TẤT CẢ'}
    else
      if Session.get('currentPriceBook').owners is undefined then 'skyReset'
      else Session.get('currentPriceBook').owners[0]


priceBookSearch  = (query) ->
  lists = []
  if Session.get("currentPriceBook").priceBookType is 0
    customerGroups = Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), isBase: false, merchant: Merchant.getId()}]}).fetch()
    customers = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
    providers = Schema.providers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
    lists = _.union(customerGroups, customers, providers)

  else if Session.get("currentPriceBook").priceBookType is 2
    if customerGroup = Schema.customerGroups.findOne(Session.get("currentPriceBook").owner)
      lists = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), _id:{$in:customerGroup.customers}}]}).fetch()

  lists


formatPriceBookSearch = (item) ->
  if item
    return "#{item.name}" if item.model is 'customers'
    return "Vùng - #{item.name}" if item.model is 'customerGroups'


scope.priceBookSelectOptions =
  query: (query) -> query.callback
    results: priceBookSearch(query)
    text: 'name'
    initSelection: (element, callback) -> callback 'skyReset'
    formatSelection: formatPriceBookSearch
    formatResult: formatPriceBookSearch
    id: '_id'
    placeholder: 'CHỌN VÙNG HOẶC KHÁCH HÀNG'
    changeAction: (e) -> scope.currentPriceBook.changePriceProductTo(e.added._id, e.added.model)
    reactiveValueGetter: -> 'skyReset'