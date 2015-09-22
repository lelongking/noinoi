notificationIconPath = "/images/notificationIcons"

Module "Wings",
  notify: (message, title = "Notification", icon = "gear.png") ->
    if Notification.permission isnt "granted"
      Notification.requestPermission()
      console.log "Required notify permission from the user!"

    Sounds.incoming.play()
    instance = new Notification title,
      body: message
      icon: "#{notificationIconPath}/#{icon}"

    Meteor.setTimeout ->
      instance.close()
    , 5000