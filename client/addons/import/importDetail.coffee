Wings.defineWidget 'importDetail',
  rendered: ->
    ProductSearch.search($('.productSearch').val())

  events:
    "click .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
    "click .remove.import-row": (event, template) -> template.data.instance.removeDetail(@_id)

    "navigate .wings-tab": (event, template, instance) -> Wings.go('import', instance.slug)
    "insert-command .wings-tab": (event, template) ->
      Document.Import.insert {}, (error, result) ->
        (console.log error; return) if error
        newImport = Document.Import.findOne(result)
        Wings.go 'import', newImport.slug
    "remove-command .wings-tab": (event, template, meta) ->
      Document.Import.remove meta.instance._id
      Wings.go('import', meta.next.slug) if meta.next