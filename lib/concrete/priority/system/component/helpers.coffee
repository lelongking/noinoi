mappingExceptions = ['ui', 'rendered', 'helpers']

Module 'Wings.Component',
  invokeIfNecessary: (method, context) -> method.apply(context, arguments) if method

  cloneTemplateEssential: (source, destination) ->
    source[name] = value for name, value of destination when !_(mappingExceptions).contains(name)
    source.helpers(destination.helpers)

  generateTemplateEssential: (source, destination) ->
    console.log "You're trying defines a not exists template" if typeof source is 'string' and !safeSource = Template[source]
    @cloneTemplateEssential(safeSource, destination)
    safeSource

  customBinding: (uiOptions, context) ->
    context.ui = {}
    context.ui[name] = $(context.find(value)) for name, value of uiOptions when typeof value is 'string'

  autoBinding: (context) ->
    context.ui = context.ui ? {}
    @bindingJQuery(context)

  bindingJQuery: (context) ->
    for item in context.findAll("[name]:not([binding])")
      name = $(item).attr('name')
      context.ui[name] = item
      context.ui["$#{name}"] = $(item)

  registerEditors: (context) ->
    Wings.Editor.register $(editor) for editor in context.findAll(".wings-editor")

  initializeApp: -> @arrangeLayout()

  arrangeLayout: ->
    newHeight = $(window).height()# - 51
    $("#container").css('height', newHeight)
    Meteor.setTimeout ->
      $(".nano").nanoScroller()
    , 1000