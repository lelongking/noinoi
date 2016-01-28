Enums = Apps.Merchant.Enums
scope = logics.providerReturn = {}

Wings.defineApp 'importReturnProductSearch',
  created: ->
    self = this
    self.autorun ()->
      if Session.get('mySession')
        #load danh sach san pham cua phieu nhap
        if parent = Schema.imports.findOne(Session.get('currentProviderReturn')?.parent)
          productQuantities = {}
          for detail in parent.details
            productQuantities[detail.product] = 0 unless productQuantities[detail.product]
            productQuantities[detail.product] += detail.basicQuantityAvailable

          for detail in parent.details
            detail.availableBasicQuantity = productQuantities[detail.product]
            detail.availableQuantity      = Math.floor(productQuantities[detail.product]/detail.conversion)

          returnParent = []
          for productId, value of productQuantities
            if product = Schema.products.findOne(productId)
              for unit in product.units
                returnParent.push({
                  product: productId
                  productUnit: unit._id
                  availableBasicQuantity: value
                  availableQuantity: Math.floor(value / unit.conversion)
                })

          for detail, index in returnParent
            found = _.findWhere(parent.details, {productUnit: detail.productUnit})
            found = _.findWhere(parent.details, {product: detail.product}) if !found
            if found
              detail.price = found.price
              detail._id = found._id
            else
              returnParent.splice(index, 1)

          Session.set 'currentReturnParent', returnParent


  rendered: ->
  destroyed: ->


  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addReturnDetail': (event, template)->
      currentImportReturn = Template.currentData().importReturn
      currentImportReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()
