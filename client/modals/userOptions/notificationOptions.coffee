Wings.defineWidget 'notificationOptions',
  events:
    "click #test-notification": (event, template) ->
      Wings.notify("Yeah, hoạt động tốt!", "Pin Notification")