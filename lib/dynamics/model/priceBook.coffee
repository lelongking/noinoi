Wings.Document.register 'priceBooks', 'PriceBook', class PriceBook
  name: ""

Document.PriceBook.attachSchema new SimpleSchema
  name:
    type: String
    index: 1
    unique: true

  creator   : Schema.creator
  slug      : Schema.slugify('PriceBook')
  version   : { type: Schema.version }