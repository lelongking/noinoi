Wings.Document.register 'plans', 'Plan', class Plan
  name: ""

Document.Plan.attachSchema new SimpleSchema
  creator   : Schema.creator
  slug      : Schema.slugify('Delivery', '_id')
  version   : { type: Schema.version }