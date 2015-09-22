Wings.Document.register 'deliveries', 'Delivery', class Delivery
  name: ""

Document.Delivery.attachSchema new SimpleSchema
  creator   : Schema.creator
  slug      : Schema.slugify('Delivery', '_id')
  version   : { type: Schema.version }