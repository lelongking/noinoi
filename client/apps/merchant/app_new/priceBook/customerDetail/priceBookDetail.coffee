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

