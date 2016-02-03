Enums = Apps.Merchant.Enums
scope = logics.productManagement

Wings.defineHyper 'productSearch',
  created: ->
    self = this
    self.searchFilter = new ReactiveVar('')

  rendered: ->

  helpers:
    activeClass: ->
      if @_id is Session.get('mySession')?.currentProduct then 'active' else ''


    productGroupLists: ->
      merchantId = Merchant.getId()
      productGroups = Schema.productGroups.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
        (productGroup) ->
          productGroup.productListSearched = []
          productGroup.hasProductList = -> productGroup.productListSearched.length > 0
          productGroup
      )

      selector = {merchant: merchantId ? Merchant.getId()};
      if searchText = Template.instance().searchFilter.get()
        regExp = Helpers.BuildRegExp(searchText);
        selector =
          $and: [
            merchant : merchantId
          ,
            $or: [{code: regExp}, {name: regExp}, {nameSearch: regExp}]
          ]


#      if Session.get('myProfile')?.roles is 'seller'
#        addProductIds = {$in: Session.get('myProfile').products}
#        if(searchText)
#          selector.$or[0]._id = addProductIds
#          selector.$or[1]._id = addProductIds
#        else
#          selector._id = addProductIds

      Schema.products.find(selector, {sort: {firstName:1 ,nameSearch: 1}}).forEach(
        (product) ->
          if productGroup = _.findWhere(productGroups, {_id: product.productOfGroup ? product.group})
            productGroup.productListSearched.push(product)
      )
      productGroups


    inStockQuantity : -> @merchantQuantities?[0].inStockQuantity ? 0

  events:
    "click .create-new-command": (event, template) ->
      FlowRouter.go('createProduct')

    "click .caption.inner.toProductGroup": (event, template) ->
      FlowRouter.go('productGroup')

    "click .list .doc-item": (event, template) ->
      if @?._id
        Product.setSession(@_id)
        Session.set('productManagementIsEditMode', false)
        Session.set('productManagementIsShowProductDetail', false)

    "keyup input[name='searchFilter']": (event, template) ->
      productSearchByInput(event, template, Template.instance())




productSearchByInput = (event, template, instance)->
  searchFilter      = instance.searchFilter
  $searchFilter     = template.ui.$searchFilter
  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    if searchFilter.get() isnt searchFilterText
      searchFilter.set(searchFilterText)
  , "productManagementSearchPeople"
  , 100