Template.wingsTip.rendered = -> Wings.Tip.Instance = $(@find(".wings-tip-wrapper"))

arrowSize = 6
Module "Wings.Tip",
  handleMouseOver: ($element) ->
    tip = $element.attr('wings-tip')
    Wings.Tip.Instance.children("#wings-tip").html(tip).promise().done ->
      Wings.Tip.Instance.removeClass 'hide'
      Wings.Tip.Instance.children("#wings-tip")
        .attr('style', Wings.Tip.getPositionStyle($element))
        .attr('class', Wings.Tip.getTipDirection($element.attr('direction')))

  handleMouseOut: -> Wings.Tip.Instance.addClass 'hide'

  getPositionStyle: ($element) ->
    targetOffset = $element.offset()
    targetHeight = $element.outerHeight()
    targetWidth  = $element.outerWidth()
    direction = $element.attr('direction') ? 'left'

    tipWidth = Wings.Tip.Instance.outerWidth()
    tipHeight = Wings.Tip.Instance.outerHeight()

    if direction is 'left'
      top  = (targetOffset.top + targetHeight / 2) - (tipHeight / 2)
      left = (targetOffset.left) - (tipWidth + arrowSize)
    else if direction is 'right'
      top  = (targetOffset.top + targetHeight / 2) - (tipHeight / 2)
      left = (targetOffset.left + targetWidth) + arrowSize
    else if direction is 'top'
      top  = targetOffset.top - (tipHeight + arrowSize)
      left = (targetOffset.left + targetWidth / 2) - (tipWidth / 2) - 2
    else # if direction is 'bottom'
      top  = (targetOffset.top + targetHeight) + arrowSize
      left = (targetOffset.left + targetWidth / 2) - (tipWidth / 2) - 2

    "left: #{left}px; top:#{top}px"

  getTipDirection: (direction) ->
    direction = direction ? 'left'

    if direction is 'left'
      return 'right-arrow'
    if direction is 'right'
      return 'left-arrow'
    if direction is 'top'
      return 'bottom-arrow'
    else
      return 'top-arrow'