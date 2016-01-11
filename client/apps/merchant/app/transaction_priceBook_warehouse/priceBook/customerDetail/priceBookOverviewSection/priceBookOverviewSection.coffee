scope = logics.priceBook
currentPriceBook = {}
Wings.defineApp 'priceBookOverviewSection',
  created: ->
    Session.set("priceBookShowEditCommand", false)
    Session.set('priceBookIsEditMode', false)
#    self = this
#    self.newPriceBookData = new ReactiveVar({})
#    self.autorun ()->
  rendered: ->

    #    scope.overviewTemplateInstance = @
    @ui.$priceBookName.autosizeInput({space: 10}) if @ui.$priceBookName
#    changePriceBookReadonly = if Session.get("customerSelectLists") then Session.get("customerSelectLists").length is 0 else true
#    $(".changePriceBook").select2("readonly", changePriceBookReadonly)
  destroyed: ->


  helpers:
    isEditMode: (text)->
      if Session.equals("priceBookIsEditMode", text) then '' else 'hidden'

    showSyncPriceBook: ->
      editCommand = Session.get("priceBookShowEditCommand")
      editMode = Session.get("priceBookIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeletePriceBook: ->
      editMode = Session.get("priceBookIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    priceBookSelected: ->
      currentPriceBook = Template.currentData()
      priceBookSelects

  events:
    "click .deletePriceBook": (event, template) ->
      if @allowDelete is true and @isBase is false
        @remove()
        $(".tooltip").remove()

    "click .unLockEditPriceBook": (event, template) ->
      Session.set('priceBookIsEditMode', true)

    "click .cancelEditPriceBook": (event, template) ->
      Session.set('priceBookIsEditMode', false)

    "click .syncEditPriceBook": (event, template) ->
      editPriceBook(template)


    'input input.priceBookEdit': (event, template) ->
      checkAllowUpdatePriceBookOverview(template)

    "keyup input.priceBookEdit": (event, template) ->
      if event.which is 13 and template.data
        editPriceBook(template)
      else if event.which is 27 and template.data
        rollBackPriceBookData(event, template)
      checkAllowUpdatePriceBookOverview(template)



#----------------------------------------------------------------------------------------------------------------------
checkAllowUpdatePriceBookOverview = (template) ->
  priceBookData        = template.data
  priceBookName        = template.ui.$priceBookName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  priceBookDescription = template.ui.$priceBookDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Session.set "priceBookShowEditCommand",
    priceBookName isnt priceBookData.name or
      priceBookDescription isnt (priceBookData.description ? '')


rollBackPriceBookData = (event, template)->
  priceBookData = template.data
  if $(event.currentTarget).attr('name') is 'priceBookName'
    $(event.currentTarget).val(priceBookData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'priceBookDescription'
    $(event.currentTarget).val(priceBookData.description)

updatePriceBookChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; priceBook = Template.currentData()
    if files.length > 0 and priceBook?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.priceBooks.update(priceBook._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(priceBook.avatar)?.remove()

editPriceBook = (template) ->
  priceBook  = template.data
  if priceBook and Session.get("priceBookShowEditCommand")
    name        = template.ui.$priceBookName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description = template.ui.$priceBookDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

    editOptions = {}
    editOptions.name          = name if name isnt priceBook.name
    editOptions.description   = description if description isnt priceBook.description

    if _.keys(editOptions).length > 0
      Schema.priceBooks.update priceBook._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Session.set("priceBookShowEditCommand", false)
      Session.set('priceBookIsEditMode', false)
      toastr["success"]("Cập nhật bảng giá.")

priceBookSearches  = (query) ->
  lists = []
  if currentPriceBook.priceBookType is 0
    customerGroups = Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), isBase: false, merchant: Merchant.getId()}]}).fetch()
    customers = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
#    providers = Schema.providers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
    providers = []
    lists = _.union(customerGroups, customers, providers)

  else if currentPriceBook.priceBookType is 2
    if customerGroup = Schema.customerGroups.findOne(currentPriceBook.owner)
      lists = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), _id:{$in:customerGroup.customerLists}}]}).fetch()

  lists


formatPriceBookSearch = (item) ->
  if item
    return "#{item.name}" if item.model is 'customers'
    return "#{item.name}" if item.model is 'providers'
    return "NHÓM - #{item.name}" if item.model is 'customerGroups'


priceBookSelects =
  query: (query) -> query.callback
    results: priceBookSearches(query)
    text: 'name'
  initSelection: (element, callback) -> callback 'skyReset'
  formatSelection: formatPriceBookSearch
  formatResult: formatPriceBookSearch
  id: '_id'
  placeholder: 'Chọn vùng hoặc khách hàng'
  changeAction: (e) ->
    if User.hasManagerRoles()
      Session.set("priceBookSelectGroup", 'selectChange')
      currentPriceBook.changePriceProductTo(e.added._id, e.added.model)
      Session.set("priceBookSelectGroup", 'skyReset')
  reactiveValueGetter: -> 'skyReset' if Session.get("priceBookSelectGroup")
