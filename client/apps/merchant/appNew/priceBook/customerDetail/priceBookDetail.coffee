Wings.defineAppContainer 'priceBookDetail',
  created: ->
  rendered: ->
  destroyed: ->

  helpers:
    currentPriceBook: ->
      if priceBookId = Session.get('mySession')?.currentPriceBook
        Schema.priceBooks.findOne({_id: priceBookId})

    isPriceBookType: ->