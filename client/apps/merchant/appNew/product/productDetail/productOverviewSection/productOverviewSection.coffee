scope = {}
Wings.defineHyper 'productOverviewSection',
  created: ->
#    self = this
#    self.newProductData = new ReactiveVar({})
#    self.autorun ()->
  rendered: ->
    Session.set('productManagementIsShowProductDetail', false)
    Session.set("productManagementShowEditCommand", false)
    Session.set('productManagementIsEditMode', false)

    scope.overviewTemplateInstance = @
    @ui.$productName.autosizeInput({space: 10}) if @ui.$productName

  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("productManagementIsShowProductDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("productManagementIsEditMode", text) then '' else 'hidden'

    showSyncProduct: ->
      editCommand = Session.get("productManagementShowEditCommand")
      editMode = Session.get("productManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteProduct: ->
      editMode = Session.get("productManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$productName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$productName?
      @name

  events:
    "click .productDelete": (event, template) ->
      console.log 'is delete'
      #TODO: xoa khach hang

    "click .editProduct": (event, template) ->
      console.log template.data
      clickShowProductDetailTab(event, template)
      Session.set('productManagementIsEditMode', true)


    "click .syncProductEdit": (event, template) ->
      editProduct(template)

    "click .cancelProduct": (event, template) ->
      Session.set('productManagementIsEditMode', false)




    "click span.hideTab": (event, template)->
      Session.set('productManagementIsShowProductDetail', false)

    "click span.showTab": (event, template)->
      clickShowProductDetailTab(event, template)



    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateChangeAvatar(event, template)



    'input input.productEdit': (event, template) ->
      checkAllowUpdateOverview(template)

    "keyup input.productEdit": (event, template) ->
      if event.which is 13 and template.data
        editProduct(template)
      else if event.which is 27 and template.data
        rollBackProductData(event, template)
      checkAllowUpdateOverview(template)


#----------------------------------------------------------------------------------------------------------------------
clickShowProductDetailTab = (event, template)->
  Session.set('productManagementIsShowProductDetail', true)

checkAllowUpdateOverview = (template) ->
  productData        = template.data
  productName        = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productCode        = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productDescription = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")


  Session.set "productManagementShowEditCommand",
    productName isnt productData.name or
      productCode isnt (productData.code ? '') or
      productDescription isnt (productData.description ? '')


rollBackProductData = (event, template)->
  productData = template.data
  if $(event.currentTarget).attr('name') is 'productName'
    $(event.currentTarget).val(productData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'productCode'
    $(event.currentTarget).val(productData.code)
  else if $(event.currentTarget).attr('name') is 'productDescription'
    $(event.currentTarget).val(productData.profiles.description)

updateChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; product = Template.currentData()
    if files.length > 0 and product?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.products.update(product._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(product.avatar)?.remove()

editProduct = (template) ->
  product   = template.data
  summaries = Session.get('merchant')?.summaries
  if product and Session.get("productManagementShowEditCommand")
    name        = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    code        = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
    listCodes   = summaries.listProductCodes ? []

    editOptions = {}
    editOptions.name    = name if name isnt product.name

    editOptions.code    = code if code isnt product.code
    editOptions.address = address if address isnt product.address
    editOptions.description = description if description isnt product.description


    console.log listCodes, editOptions.code, _.indexOf(listCodes, editOptions.code)
    if editOptions.name isnt undefined  and editOptions.name.length is 0
      template.ui.$productName.notify("Tên khách hàng không thể để trống.", {position: "right"})

    else if editOptions.code isnt undefined
      if editOptions.code.length > 0
        if listCodes.length > 0 and _.indexOf(listCodes, editOptions.code) isnt -1
          return template.ui.$productCode.notify("Mã khách hàng đã tồn tại.123123123", {position: "right"})
      else
        return template.ui.$productCode.notify("Mã khách hàng không thể để trống.", {position: "right"})

    else if editOptions.phone isnt undefined and listPhones.length > 0 and _.indexOf(listPhones, editOptions.phone) isnt -1
      return template.ui.$productPhone.notify("Số điện thoại đã tồn tại.", {position: "right"})


    if _.keys(editOptions).length > 0
      Schema.products.update product._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Session.set("productManagementShowEditCommand", false)
      Session.set('productManagementIsEditMode', false)
      toastr["success"]("Cập nhật sản phẩm thành công.")


