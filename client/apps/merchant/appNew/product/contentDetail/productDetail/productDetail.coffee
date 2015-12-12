Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineAppContainer 'productDetail',
  created: ->
  rendered: ->
  destroyed: ->

  helpers:
    currentProduct: ->
      if productId = Session.get('mySession')?.currentProduct
        Schema.products.findOne({_id: productId})


#  events:

