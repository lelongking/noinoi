Enums = Apps.Merchant.Enums
logics.productManagement = {} unless logics.productManagement
scope = logics.productManagement


scope.productManagementCreationMode = (productSearch)->
  if ProductSearch.history[productSearch].data?.length is 1
    nameIsExisted = ProductSearch.history[productSearch].data[0].name isnt Session.get("productManagementSearchFilter")
  Session.set("productManagementCreationMode", nameIsExisted)

scope.createNewProduct = (template, productSearch) ->
  fullText   = Session.get("productManagementSearchFilter")
  newProduct = Helpers.splitName(fullText)
  newProduct.merchant = Session.get("myProfile").merchant

  if Product.nameIsExisted(newProduct.name, newProduct.merchant)
    template.ui.$searchFilter.notify("Sản phẩm đã tồn tại.", {position: "bottom"})
  else
    ProductSearch.cleanHistory() if Match.test(Product.insert(newProduct), String)


scope.deleteNewProductUnit = (unit, event, template) ->
  if unit.allowDelete
    scope.currentProduct.unitRemove(unit._id)

scope.createNewProductUnit = (event, template) ->
  $unitName       = template.ui.$unitName
  $unitConversion = template.ui.$unitConversion
  name = $unitName.val()
  conversion = Number $unitConversion.val()

  unitNameIsExisted = false;
  for unit in scope.currentProduct.units
    unitNameIsExisted = true if unit.name is name

  if unitNameIsExisted
    $unitName.notify("Đơn vị tính đã có.", {position: "bottom"})
  else if isNaN(conversion)
    $unitConversion.notify("Quy đổi phải là số.", {position: "bottom"})
  else if conversion < 1
    $unitConversion.notify("Quy đổi lớn hơn 1.", {position: "bottom"})
  else
    if scope.currentProduct.unitCreate(name, conversion)
      $unitName.val(''); $unitConversion.val('')