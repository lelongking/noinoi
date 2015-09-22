Wings.defineHyper 'import',
  events:
    "click .create-command": (event, template) ->
      Document.Import.insert {}, (error, result) ->
        (console.log error; return) if error
        newImport = Document.Import.findOne(result)
        Wings.go 'import', newImport.slug

    "click .goto-product": (event, template) -> Wings.go('product')
    "click .import-item": (event, template) -> Wings.go('import', @slug)
    "click .product-item": -> Template.currentData().instance.addDetail(@_id)
    "keyup input.productSearch": (event, template) ->
      if event.which is 17
        console.log 'up'
      else
        ProductSearch.search(Wings.Helpers.Searchify(template.ui.$productSearch.val()))