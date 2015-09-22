Wings.defineWidget 'news',
  helpers:
    products: -> Document.News.find()
    zeroState: -> !Document.News.findOne()