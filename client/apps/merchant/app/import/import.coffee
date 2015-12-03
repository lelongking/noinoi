scope = logics.import

Wings.defineApp 'import',
  created: ->
    self = this
    self.autorun ()->
      if Session.get('mySession')
        scope.currentImport = Schema.imports.findOne Session.get('mySession').currentImport
        Session.set 'currentImport', scope.currentImport

      newProviderId = Session.get('currentImport')?.provider
      oldProviderId = Session.get('currentProvider')?._id
      if newProviderId
        Session.set('currentProvider', Schema.providers.findOne newProviderId) if !oldProviderId or oldProviderId isnt newProviderId
      else
        Session.set 'currentProvider'

    UnitProductSearch.search('')

  rendered: -> scope.templateInstance = @

  helpers:
    tabOptions            : -> scope.tabOptions
    currentImport         : -> Session.get('currentImport')
    providerSelectOptions : -> scope.providerSelectOptions
    depositOptions        : -> scope.depositOptions
    discountOptions       : -> scope.discountOptions
    debtDateOptions       : -> scope.debtDateOptions

  events:
    "click .print-command": -> window.print()

    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch

    'click .addImportDetail': (event, template)->
      scope.currentImport.addImportDetail(@_id) if @inventoryInitial
      event.stopPropagation()

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

