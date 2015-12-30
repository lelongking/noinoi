scope = logics.import = {}
Wings.defineApp 'importLayout',
  created: ->
    self = this
    self.currentImport = new ReactiveVar({})
    self.autorun ()->
      if Session.get('mySession')
        scope.currentImport = Schema.imports.findOne Session.get('mySession').currentImport
        self.currentImport.set(scope.currentImport)
        Session.set 'currentImport', scope.currentImport

      newProviderId = Session.get('currentImport')?.provider
      oldProviderId = Session.get('currentProvider')?._id
      if newProviderId
        Session.set('currentProvider', Schema.providers.findOne newProviderId) if !oldProviderId or oldProviderId isnt newProviderId
      else
        Session.set 'currentProvider'

    UnitProductSearch.search('')

  rendered: ->

  helpers:
    currentImport         : -> Template.instance().currentImport.get()
    allowSubmitOrder      : ->
      currentImport = Template.instance().currentImport.get()
      return 'disabled' if !currentImport

      importDetails = currentImport.details
      return 'disabled' if !importDetails or !currentImport.provider or importDetails.length is 0

      for importDetail in importDetails
        return 'disabled' if importDetail.quality is 0



    tabOptions            : -> tabOptions
    providerSelectOptions : -> providerSelectOptions
    depositOptions        : -> depositOptions
    discountOptions       : -> discountOptions
    debtDateOptions       : -> debtDateOptions

  events:
    "click .print-command": -> window.print()

    'click .importSubmit': (event, template)->
      if currentImport = Session.get('currentImport')
        importLists = Import.findNotSubmitted().fetch()
        if nextRow = importLists.getNextBy("_id", currentImport._id)
          Import.setSession(nextRow._id)
        else if previousRow = importLists.getPreviousBy("_id", currentImport._id)
          Import.setSession(previousRow._id)
        else
          Import.setSession(Import.insert())

        scope.currentImport.importSubmit()



tabOptions =
  source: -> Import.findNotSubmitted()
  currentSource: 'currentImport'
  caption: 'importName'
  key: '_id'
  createAction  : ->
    importId = Import.insert()
    Import.setSession(importId)
  destroyAction : (instance) ->
    return -1 if !instance
    instance.remove()
    Import.findNotSubmitted().count()
  navigateAction: (instance) ->
    Import.setSession(instance._id)

depositOptions =
  reactiveSetter: (val) -> scope.currentImport.changeField('depositCash', val)
  reactiveValue: -> Session.get('currentImport')?.depositCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

discountOptions =
  reactiveSetter: (val) -> scope.currentImport.changeField('discountCash', val)
  reactiveValue: -> Session.get('currentImport')?.discountCash ? 0
  reactiveMax: -> Session.get('currentImport')?.totalPrice ? 0
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

debtDateOptions =
  reactiveSetter: (val) -> scope.currentImport.changeDueDay(val)
  reactiveValue: -> Session.get('currentImport')?.dueDay ? 90
  reactiveMax: -> 180
  reactiveMin: -> 0
  reactiveStep: -> 30
  others:
    forcestepdivisibility: 'none'



updateImportAndProduct = (e)->
  if e.added
    if e.added.merchantType then importUpdate = {$set: {partner: e.added._id}, $unset: {distributor: true}}
    else importUpdate = {$set: {distributor: e.added._id}, $unset: {partner: true}}
    importUpdate.$set.tabDisplay = Helpers.shortName2(e.added.name)
  else
    importUpdate = { $set:{tabDisplay: 'Nhập kho'}, $unset:{distributor: true, partner: true} }
  Schema.imports.update Session.get('currentImport')._id, importUpdate


providerSearch       = (query) -> ProviderSearch.search(query.term); ProviderSearch.getData({sort: {name: 1}})
formatProviderSearch = (item) -> "#{item.name}" if item

providerSelectOptions =
  query: (query) -> query.callback
    results: providerSearch(query)
    text: 'name'
  initSelection: (element, callback) -> callback Schema.providers.findOne(scope.currentImport.provider)
  formatSelection: formatProviderSearch
  formatResult: formatProviderSearch
  id: '_id'
  placeholder: 'CHỌN NHÀ PHÂN PHỐI'
  changeAction: (e) -> scope.currentImport.changeField('provider', e.added._id)
  reactiveValueGetter: -> Session.get('currentImport')?.provider ? 'skyReset'