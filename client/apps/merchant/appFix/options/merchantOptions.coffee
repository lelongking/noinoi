scope = logics.merchantOptions

Wings.defineAppContainer 'merchantOptions',
  helpers:
    settings: -> scope.settings
    currentSectionDynamic: -> Session.get("merchantOptionsCurrentDynamics")
    optionActiveClass: -> if @template is Session.get("merchantOptionsCurrentDynamics")?.template then 'active' else ''

  created: ->
    self = this
    self.autorun ()->
      if Session.get("myProfile")
        scope.myProfile = Session.get("myProfile")
        if !Session.get("merchantOptionsCurrentDynamics") and scope.settings?.system
          Session.set "merchantOptionsCurrentDynamics", scope.settings.system[0]

  rendered: -> console.log 'rendered'
  events:
    "click .caption.inner": -> Session.set("merchantOptionsCurrentDynamics", @)