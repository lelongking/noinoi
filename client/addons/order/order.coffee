Wings.defineHyper 'order',
  events:
    "click .create-command": (event, template) ->
      Document.Order.insert {
        creator    : Meteor.userId()
      }, (error, result) ->
        (console.log error; return) if error
        newOrder = Document.Order.findOne(result)
        Wings.go 'order', newOrder.slug

    "click .goto-product": (event, template) -> Wings.go('product')
    "click .order-item": (event, template) -> Wings.go('order', @slug)
    "click .product-item": (event, template) -> Template.currentData().instance.addDetail(@_id)
    "keyup input.productSearch": (event, template) ->
      if event.which is 17
        console.log 'up'
      else
        ProductSearch.search(Wings.Helpers.Searchify(template.ui.$productSearch.val()))

Wings.defineHyper 'productSearches',
  helpers:
    dynamicPrice: ->
      priceType = Template.instance().data.type ? 'sale'
      for price in Template.parentData().prices
        return price[priceType] if price.unit is @_id
      return 0