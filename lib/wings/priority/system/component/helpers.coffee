mappingExceptions = ['ui', 'rendered', 'helpers']
youtubeSizeRatio = 0.5625

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
    @bindingToolTip(context)
    @bindingJQuery(context)
    @bindingSwitch(context)
    @bindingDatePicker(context)
    @bindingExtras(context)

  bindingToolTip: (context) ->
    $("[data-toggle='tooltip']").tooltip({container: 'body'})

  bindingJQuery: (context) ->
    for item in context.findAll("[name]:not([binding])")
      name = $(item).attr('name')
      context.ui[name] = item
      context.ui["$#{name}"] = $(item)

  bindingSwitch: (context) ->
    context.switch = {}
    for item in context.findAll("input[binding='switch'][name]")
      context.switch[$(item).attr('name')] = new Switchery(item)

  bindingDatePicker: (context) ->
    context.datePicker = {}
    for item in context.findAll("[binding='datePicker'][name]")
      $item = $(item)
      name = $item.attr('name')
      options = {}
      options.language = 'vi'
      options.autoclose = true
      options.todayHighlight = true if $item.attr('todayHighlight') is true
      $item.datepicker(options)
      context.datePicker["$#{name}"] = $item

  bindingExtras: (context) ->
    context.ui.extras = {}
    for extra in context.findAll(".editor-row.extra[name]")
      $extra = $(extra)
      name = $extra.attr('name')
      visible = $extra.attr('visibility') ? false
      $extra.show() if visible
      context.ui.extras[name] = { visibility: visible, $element: $extra }
    context.ui.extras.toggleExtra = (name, mode = true) -> toggleExtra(name, context, mode)

  registerEditors: (context) ->
    Wings.Editor.register $(editor) for editor in context.findAll(".wings-editor")

  initializeApp: -> @arrangeLayout()

  arrangeLayout: ->
    $(".nano").nanoScroller()
    newHeight = $(window).height() - $("#header").outerHeight() - $("#footer").outerHeight()
    $("#container").css('height', newHeight)

#    newHeight = $(window).height()
#    $("#container").css('height', newHeight)
#    if $videoContainer = $(".video-container")
#      videoContainerWidth = $videoContainer.outerWidth()
#      videoContainerHeight = videoContainerWidth * youtubeSizeRatio
#      $("#episodeFrame").width(videoContainerWidth)
#      $("#episodeFrame").height(videoContainerHeight)

