Wings.Document.register 'customers', 'Customer', class Customer
  @transform: (doc) ->
    doc.update = (option, callback) ->
      return unless typeof option is "object"

      updateCustomer = {}
      if option.businessOwner and option.businessOwner isnt doc.businessOwner
        updateCustomer.$set = {businessOwner: option.businessOwner}
      else if option.businessOwner is ""
        updateCustomer.$unset = {businessOwner: ""}

      if option.phone and option.phone isnt doc.phone
        updateCustomer.$set = {phone: option.phone}
      else if option.phone is ""
        updateCustomer.$unset = {phone: ""}

      if option.address and option.address isnt doc.address
        updateCustomer.$set = {address: option.address}
      else if option.address is ""
        updateCustomer.$unset = {address: ""}

      Document.Customer.update doc._id, updateCustomer, callback


Document.Customer.attachSchema new SimpleSchema
  name:
    type: String
    index: 1
    unique: true

  businessOwner:
    type: String
    optional: true

  address:
    type: String
    optional: true

  phone:
    type: String
    optional: true

  description:
    type: String
    optional: true

  image:
    type: String
    optional: true

  plans              : type: [Object], defaultValue: []
  'plans.$._id'      : type: String
  'plans.$.sale'     : type: String
  'plans.$.seller'   : type: String
  'plans.$.createdAt': type: String

  events              : type: [Object], defaultValue: []
  'events.$.owner'    : type: String
  'events.$.content'  : type: String
  'events.$.createdAt': type: Date


  creator   : Schema.creator
  slug      : Schema.slugify('Customer', 'name')
  version   : { type: Schema.version }