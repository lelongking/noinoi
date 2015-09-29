Wings.defineWidget 'requestDetails',
  helpers:
    requests: -> logics.merchantNotification.requests
    unreadRequests: -> logics.merchantNotification.unreadRequests