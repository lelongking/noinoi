@siderAlertFadeTimeout = null

hideSiderAlert = ->
  window.siderAlertFadeTimeout = Meteor.setTimeout ->
    Wings.SiderAlert.Instance.children("#sider-alert").removeClass().addClass 'animated fadeOutRight pointer-event-off'
  , 5000

hideSiderAlertPromise = ->
  Wings.SiderAlert.Instance.children("#sider-alert").removeClass().addClass 'animated fadeOutRight pointer-event-off'
  $(@).off event.type, hideSiderAlertPromise

Template.siderAlert.rendered = -> Wings.SiderAlert.Instance = $(@find(".sider-alert-wrapper"))
Template.siderAlert.events
  "mouseover": -> Meteor.clearTimeout(siderAlertFadeTimeout)
  "mouseout": -> hideSiderAlert() if siderAlertFadeTimeout

Module "Wings.SiderAlert",
  show: ($element, content, $hideOn, hideEvent = 'blur') ->
    targetOffset = $element.offset()
    targetHeight = $element.outerHeight()

    Wings.SiderAlert.Instance.children("#sider-alert").html(content).promise().done ->
      Meteor.clearTimeout(siderAlertFadeTimeout)
      newTop = targetOffset.top + (targetHeight / 2) - (Wings.SiderAlert.Instance.outerHeight() / 2)
      newLeft = window.innerWidth - 405
      Wings.SiderAlert.Instance.attr('style', "top: #{newTop}px; left: #{newLeft}px")
      Wings.SiderAlert.Instance.children("#sider-alert")
      .removeClass().addClass('animated bounceIn')

      if $hideOn
        $hideOn.on(hideEvent, hideSiderAlertPromise)
      else
        hideSiderAlert()