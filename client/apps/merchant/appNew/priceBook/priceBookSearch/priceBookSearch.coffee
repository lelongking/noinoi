getPriceBook = (priceBookFounds) ->
  priceBookLists = []
  priceBookFounds =_.groupBy priceBookFounds, (priceBook) ->
    if priceBook.priceBookType is 0 then 'Cơ Bản'
    else if priceBook.priceBookType is 1 then 'Khách Hàng'
    else if priceBook.priceBookType is 2 then 'Khu Vực - Vùng'
    else if priceBook.priceBookType is 3 then 'Nhà Cung Cấp'
    else if priceBook.priceBookType is 4 then 'Nhóm Nhà Cung Cấp'

  priceBookLists.push {_id: key, childs: childs} for key, childs of priceBookFounds
  return priceBookLists

Wings.defineHyper 'priceBookSearch',
  created: ->
    console.log 'created priceBookSearch'
    self = this
    self.currentPriceBook = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if priceBookId = Session.get('mySession')?.currentPriceBook
        self.currentPriceBook.set(Schema.priceBooks.findOne(priceBookId))

  rendered: ->

  helpers:
    currentPriceBook: ->
      Template.instance().currentPriceBook.get()

    activeClass: ->
      if @_id is Template.instance().currentPriceBook.get()?._id then 'active' else ''

    isPriceBookType: (bookType)->
      priceType = Session.get("currentPriceBook").priceBookType
      return true if bookType is 'default' and priceType is 0
      return true if bookType is 'customer' and (priceType is 1 or priceType is 2)
      return true if bookType is 'provider' and (priceType is 3 or priceType is 4)


    priceBookLists: ->
      console.log 'reactive....'
      selector = {}; options  = {sort: {priceBookType: 1, name: 1}}
      searchText = Template.instance().searchFilter.get()
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {name: regExp}
        ]}
      priceBookFounds = Schema.priceBooks.find(selector, options).fetch()
      getPriceBook(priceBookFounds)


  events:
#    "click .create-new-command": (event, template) ->
#      FlowRouter.go('createPriceBook')

    "click .list .doc-item": (event, template) ->
      selectPriceBook(event, template, @)

    "keyup input[name='searchFilter']": (event, template) ->
      priceBookSearchByInput(event, template, Template.instance())




priceBookSearchByInput = (event, template, instance)->
  searchFilter      = instance.searchFilter
  $searchFilter     = template.ui.$searchFilter
  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    if searchFilter.get() isnt searchFilterText
      searchFilter.set(searchFilterText)
  , "priceBookManagementSearchPeople"
  , 100

selectPriceBook = (event, template, priceBook)->
  if userId = Meteor.userId()
#    Wings.SubsManager.subscribe('getPriceBookId', priceBook._id)
    Meteor.users.update(userId, {$set: {'sessions.currentPriceBook': priceBook._id}})
    Session.set('priceBookManagementIsShowPriceBookDetail', false)
    Session.set('priceBookManagementIsEditMode', false)
