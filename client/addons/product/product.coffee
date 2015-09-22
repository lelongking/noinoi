Wings.defineHyper 'product',
  helpers:
    products: -> Document.Product.find()
  events:
    "click .doc-item": -> Wings.go('product', @slug)
    "keyup input.insert": (event, template) ->
      if event.which is 13
        $name = $(template.find(".wings-field.insert"))
        Document.Product.insert { creator: Meteor.userId(), name: $name.val() }, (error, result) ->
          (console.log error; return) if error
          newProduct = Document.Product.findOne(result)
          Wings.go 'product', newProduct.slug
