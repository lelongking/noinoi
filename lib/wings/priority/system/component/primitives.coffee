componentHelper = Wings.Component

Module 'Wings',
  defineApp: (source, destination) ->
    source = componentHelper.generateTemplateEssential(source, destination)

    source.rendered = ->
      componentHelper.customBinding(destination.ui, @) if destination.ui
      componentHelper.autoBinding(@)
      componentHelper.invokeIfNecessary(destination.rendered, @)
      componentHelper.initializeApp()

  defineWidget: (source, destination) ->
    source = componentHelper.generateTemplateEssential(source, destination)

    source.rendered = ->
      componentHelper.customBinding(destination.ui, @) if destination.ui
      componentHelper.invokeIfNecessary(destination.rendered, @)

  defineHyper: (source, destination) ->
    source = componentHelper.generateTemplateEssential(source, destination)

    source.rendered = ->
      componentHelper.customBinding(destination.ui, @) if destination.ui
      componentHelper.autoBinding(@)
      componentHelper.invokeIfNecessary(destination.rendered, @)
      componentHelper.registerEditors(@)

  defineAppContainer: (source, destination) ->
    source = componentHelper.generateTemplateEssential(source, destination)

    source.rendered = ->
      componentHelper.invokeIfNecessary(destination.rendered, @)
      componentHelper.arrangeLayout()