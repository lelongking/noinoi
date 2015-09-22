Wings.defineHyper 'regionInput',
  helpers:
    activeClass: -> if Template.instance().hasFocus.get() then 'active' else ''
    prefixClass: -> if @prefix then 'prefix' else ''
  created: -> Template.instance().hasFocus = new ReactiveVar(false)
  rendered: ->
    if @data.value
      if @data.type is 'number'
        @ui.$source.val accounting.formatNumber(@data.value)
      else
        @ui.$source.val @data.value

    $(@find("input")).attr('side-explain', @data.explain) if @data.explain

  events:
    "focus input": -> Template.instance().hasFocus.set(true)
    "blur input": -> Template.instance().hasFocus.set(false)
    "input input": (event, template) ->
      value = template.ui.$source.val()
      if template.data.type is 'number'
        template.ui.$source.val(accounting.formatNumber(value))
        value = accounting.parse(value)

      template.ui.$wrapper.trigger("wings-change", value)