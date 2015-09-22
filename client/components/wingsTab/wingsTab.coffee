Wings.defineWidget 'wingsTab',
  ui:
    $component: ".wings-tab"

  helpers:
    dynamicCaption: -> @[Template.instance().data.caption] ? "Caption"
    activeClass: -> if @slug is Session.get(Template.instance().data.active) then 'active' else ''

  events:
    "click .tab-item": (event, template) -> template.ui.$component.trigger('navigate', @)
    "click .insert-command": (event, template) -> template.ui.$component.trigger('insert-command')
    "dblclick .remove-command": (event, template) ->
      sources = template.data.sources.fetch()
      next = sources.getNextBy("_id", @_id) ? sources.getPreviousBy("_id", @_id)
      template.ui.$component.trigger('remove-command', {instance: @, next: next})
      event.stopPropagation()