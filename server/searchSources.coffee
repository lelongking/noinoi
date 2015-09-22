#SearchSource.defineSource 'products', (searchText, options) ->
#  options = {sort: {isoScore: -1}, limit: 20}
##  predicate = if searchText then {$text: {$search:searchText, $language: 'en'}} else {}
##  Document.Product.find(predicate, options).fetch()
#  if searchText
#    regExp = buildRegExp(searchText)
#    return Schema.products.find({name: regExp}, options).fetch()
#  else
#    return Schema.products.find({}, options).fetch()
#
#buildRegExp = (searchText) ->
#  parts = searchText.trim().split(/[ \-\:]+/);
#  return new RegExp("(" + parts.join('|') + ")", "ig");

#data = []
#for item in data
#  customerInsert = {name: item.name}
#  if item.phone or item.address
#    customerInsert.profiles = {}
#    customerInsert.profiles.phone = item.phone if item.phone
#    customerInsert.profiles.address = item.address if item.address
#
#  unless Schema.customers.findOne({name: item.name})
#    newCustomerId = Schema.customers.insert(customerInsert)
#    CustomerGroup.addCustomer(newCustomerId)
#
#
#
#Schema.products.find({}).forEach(
#  (product)->
#    Schema.products.update(product._id, $set: {group: "JEWNp6EntMwT8HByb"})
#    Schema.productGroups.update("JEWNp6EntMwT8HByb", $addToSet: {products: product._id })
#    Schema.priceBooks.update("w3Bg4m8jimv4obbEM", {$addToSet: {products: product._id}})
#
#    return
#)

#
#data = []
#for item in data
#  productInsert = {name: item.name + ' - ' + item.skull}
#  unless Schema.customers.findOne(productInsert)
#    productInsert.unitBasicName = item.dvt if item.dvt
#    Product.insert(productInsert)
