Wings.defineHyper 'delivery',
  helpers:
    deliveries: -> Document.Delivery.find()
  events:
    "click .doc-item": -> Wings.go('delivery', @slug)
    "keyup input.insert": (event, template) ->
      if event.which is 13
        $description = $(template.find(".wings-field.insert"))
        Document.Delivery.insert { description: $description.val() }, (error, result) ->
          (console.log error; return) if error
          newDelivery = Document.Delivery.findOne(result)
          Wings.go 'delivery', newDelivery.slug