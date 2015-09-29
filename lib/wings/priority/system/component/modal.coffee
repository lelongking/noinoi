componentHelper = Wings.Component

Wings.Component.modals = []
modalEssentialEvents =
  "click .modal-backdrop, click .close-modal": (event, template) ->
#    $(template.find(".modal-backdrop")).hide()
    $element = $(template.find(".modal-backdrop"))
    $element.removeClass('fadeIn').addClass('fadeOut pointer-event-off')
    $element.children(".modal-wrapper").removeClass('bounceInDown').addClass('fadeOutUpBig')
    Meteor.setTimeout ->
      Session.set("currentActiveModal")
    , 900

  "click .modal-wrapper": (event, template) -> event.stopPropagation()

Module 'Wings',
  showModal: (modal) -> Session.set("currentActiveModal", modal)
  defineModal: (source, destination) ->
    Wings.Component.modals.push source
    source = componentHelper.generateTemplateEssential(source, destination)

    source.rendered = ->
      componentHelper.customBinding(destination.ui, @) if destination.ui
      componentHelper.invokeIfNecessary(destination.rendered, @)

    source.events = source.events ? {}
    source.events[evt] = detail for evt, detail of modalEssentialEvents