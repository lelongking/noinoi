Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineAppContainer 'productDetail',
  created: ->
  rendered: ->
  destroyed: ->

  helpers:
    currentProduct: ->
      productId = Session.get('mySession')?.currentProduct
      if productId
        product      = Schema.products.findOne({_id: productId})
        if product
          productGroup = Schema.productGroups.findOne({_id: product.productOfGroup})
          Session.set("productManagementSelectedGroup", productGroup)
        product

#  events:
