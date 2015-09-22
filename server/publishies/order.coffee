Customer = find: (order) -> Document.Customer.find order.buyer, limit: 1
Products =
  find: (order) ->
    productIds = order.details.map (doc) -> doc.product
    Document.Product.find {_id: {$in: productIds}}

Meteor.publishComposite "order", (slug) ->
  find: ->
    Document.Order.find({slug : slug})
  children: [Customer, Products]