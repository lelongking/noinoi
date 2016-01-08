priceBook = {}
Wings.defineAppContainer 'priceBookDetail',
  created: ->
  rendered: ->
  destroyed: ->

  helpers:
    currentPriceBook: ->
      if priceBookId = Session.get('mySession')?.currentPriceBook
        priceBook = Schema.priceBooks.findOne({_id: priceBookId})

    priceBookDetailShow: ->
      priceType = priceBook.priceBookType
      console.log priceType
      if priceType is 0
        'defaultPriceBookDetailSection'
      else if (priceType is 1 or priceType is 2)
        'customerPriceBookDetailSection'
      else if (priceType is 3 or priceType is 4)
        'providerPriceBookDetailSection'

  events:
    "click th.selectAll": (event, template) ->
      if priceBook?.products.length > 0
        productLists = _.difference(priceBook.products, Session.get('mySession').productUnitSelected?[priceBook._id])
        if productLists.length > 0
          priceBook.selectedPriceProduct(productId) for productId in productLists
        else
          priceBook.unSelectedPriceProduct(productId) for productId in priceBook.products