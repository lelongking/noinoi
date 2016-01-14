Enums = Apps.Merchant.Enums

Wings.defineHyper 'merchantNoteOptions',
  helpers:
    merchantNotes: -> Session.get('merchant')?.noteOptions

  events:
    "keyup": (event, template) ->
      merchant = Session.get('merchant')
      if event.target.name is "customerReceivable"
        $customerReceivable    = template.ui.$customerReceivable
        customerReceivableText = $customerReceivable.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and customerReceivableText isnt merchant.noteOptions?.customerReceivable
          Schema.merchants.update merchant._id, $set: {'noteOptions.customerReceivable': customerReceivableText}

      else if event.target.name is "customerPayable"
        $customerPayable    = template.ui.$customerPayable
        customerPayableText = $customerPayable.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and customerPayableText isnt merchant.noteOptions?.customerPayable
          Schema.merchants.update merchant._id, $set: {'noteOptions.customerPayable': customerPayableText}
          
      else if event.target.name is "customerSale"
        $customerSale    = template.ui.$customerSale
        customerSaleText = $customerSale.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and customerSaleText isnt merchant.noteOptions?.customerSale
          Schema.merchants.update merchant._id, $set: {'noteOptions.customerSale': customerSaleText}

      else if event.target.name is "customerReturn"
        $customerReturn    = template.ui.$customerReturn
        customerReturnText = $customerReturn.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and customerReturnText isnt merchant.noteOptions?.customerReturn
          Schema.merchants.update merchant._id, $set: {'noteOptions.customerReturn': customerReturnText}

      else if event.target.name is "providerReceivable"
        $providerReceivable    = template.ui.$providerReceivable
        providerReceivableText = $providerReceivable.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and providerReceivableText isnt merchant.noteOptions?.providerReceivable
          Schema.merchants.update merchant._id, $set: {'noteOptions.providerReceivable': providerReceivableText}

      else if event.target.name is "providerPayable"
        $providerPayable    = template.ui.$providerPayable
        providerPayableText = $providerPayable.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and providerPayableText isnt merchant.noteOptions?.providerPayable
          Schema.merchants.update merchant._id, $set: {'noteOptions.providerPayable': providerPayableText}

      else if event.target.name is "providerImport"
        $providerImport    = template.ui.$providerImport
        providerImportText = $providerImport.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and providerImportText isnt merchant.noteOptions?.providerImport
          Schema.merchants.update merchant._id, $set: {'noteOptions.providerImport': providerImportText}

      else if event.target.name is "providerReturn"
        $providerReturn    = template.ui.$providerReturn
        providerReturnText = $providerReturn.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if merchant and providerReturnText isnt merchant.noteOptions?.providerReturn
          Schema.merchants.update merchant._id, $set: {'noteOptions.providerReturn': providerReturnText}