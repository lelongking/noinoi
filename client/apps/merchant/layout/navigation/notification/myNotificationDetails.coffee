Wings.defineWidget 'myNotificationDetails',
  helpers:
    notifies: -> logics.merchantNotification.myNotifies
    unreadNotifies: -> logics.merchantNotification.unreadNotifies