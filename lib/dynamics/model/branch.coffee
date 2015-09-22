Wings.Document.register 'branches', 'Branch', class Branch
  @insert: (doc, callback) -> @document.insert doc, callback

Module "Schema",
  warehouse: new SimpleSchema
    _id: Schema.uniqueId

    name:
      type: String

    isBase:
      type: Boolean
      defaultValue: false

Document.Branch.attachSchema new SimpleSchema
  name:
    type: String
    index: 1
    unique: true

  description:
    type: String
    optional: true

  image:
    type: String
    optional: true

  isBase:
    type: Boolean
    defaultValue: false

  creator   : Schema.creator
  slug      : Schema.slugify('Product')
  version   : { type: Schema.version }