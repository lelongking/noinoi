addons = ['news', 'plan', 'product', 'customer', 'user', 'order', 'import', 'delivery']
actions = ['detail', 'edit']
kernelAddonRegion = { to: "kernelAddon" }
kernelAppRegion   = { to: 'kernelApp' }

Module "Wings.Router",
  findChannel: (slug) ->
    chanelResult = {}
    if slug?.substr(0, 1) is "@"
      chanelResult.instance = Meteor.users.findOne({'slug': slug.substr(1)})
      chanelResult.isDirect = true
    else
      chanelResult.instance = Document.Channel.findOne({slug: slug})
    chanelResult

  isValid: (scope) -> return _(addons).contains(scope.params.sub)
  renderAddonNotFound: (scope) -> scope.render 'addonNotFound', kernelAppRegion
  renderAddonDocumentNotFound: (scope) -> scope.render 'addonDocumentNotFound', kernelAppRegion
  renderAddonDefault: (scope) -> scope.render scope.params.sub, kernelAddonRegion
  renderKernelMessenger: (scope) -> scope.render 'kernel', kernelAppRegion

  renderApplication: (scope) ->
    if @isValid(scope)
      @renderAddonDefault(scope)

      if documentWantedAndExist(scope)
        Session.set("activeDocumentSlug", scope.params.subslug)
        @renderAddonDetail(scope)
      else if documentWanted(scope)
        @renderAddonDocumentNotFound(scope)
      else
        @renderKernelMessenger(scope)
    else
      @renderAddonNotFound(scope)

  #this mean the document is exist! check for action
  renderAddonDetail: (scope) ->
    if scope.params.action
      childTemplate = "#{scope.params.sub}#{scope.params.action.toCapitalize()}"
      if Template[childTemplate]
        scope.render childTemplate, kernelAppRegion
      else
        @renderAddonNotFound(scope)
    else
      scope.render "#{scope.params.sub}Detail", kernelAppRegion

documentWantedAndExist = (scope) -> scope.params.subslug and Document[scope.params.sub.toCapitalize()]?.findOne({slug: scope.params.subslug})
documentWanted = (scope) -> !!scope.params.subslug