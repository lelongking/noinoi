Wings.Document.register 'staffs', 'Staff', class Staff
  name: ""

Document.Staff.attachSchema new SimpleSchema
  name:
    type: String
    index: 1
    unique: true

  image:
    type: String
    optional: true

  branch:
    type: String
    optional: true

  creator   : Schema.creator
  slug      : Schema.slugify('Staff')
  version   : { type: Schema.version }