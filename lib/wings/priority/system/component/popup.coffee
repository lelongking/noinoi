return unless Meteor.isClient

@$popupInstance = null

hidePopup = ->
  window.$popupInstance?.addClass('hide')
  window.$popupInstance = null
  $(document).off 'click', hidePopup

Module 'Wings',
  showPopup: ($instance, event) ->
    event.stopPropagation() if !window.$popupInstance
    window.$popupInstance = $instance
    $instance.removeClass()
    $(document).on 'click', hidePopup