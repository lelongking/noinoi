logics.import = {} unless logics.import
Enums = Apps.Merchant.Enums
scope = logics.import


scope.tabOptions =
  source: -> Import.findNotSubmitted()
  currentSource: 'currentImport'
  caption: 'importName'
  key: '_id'
  createAction  : -> Import.insert()
  destroyAction : (instance) ->
    if instance
      instance.remove()
      Import.findNotSubmitted().count()
    else -1
  navigateAction: (instance) -> Import.setSession(instance._id)

scope.depositOptions =
  reactiveSetter: (val) -> scope.currentImport.changeField('depositCash', val)
  reactiveValue: -> Session.get('currentImport')?.depositCash ? 0
  reactiveMax: -> 99999999999
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.discountOptions =
  reactiveSetter: (val) -> scope.currentImport.changeField('discountCash', val)
  reactiveValue: -> Session.get('currentImport')?.discountCash ? 0
  reactiveMax: -> Session.get('currentImport')?.totalPrice ? 0
  reactiveMin: -> 0
  reactiveStep: -> 1000
  others:
    forcestepdivisibility: 'none'

scope.debtDateOptions =
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

scope.providerSelectOptions =
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