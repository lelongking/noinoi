Wings.defineWidget 'merchantPrintingHeader',
  helpers:
    dayOfWeek: -> moment(Session.get('realtime-now')).format("dddd")
    timeDMY: -> moment(Session.get('realtime-now')).format("DD/MM/YYYY")
    timeHM: -> moment(Session.get('realtime-now')).format("HH:mm")
    timeS: -> moment(Session.get('realtime-now')).format("ss")

    merchantInfo: -> Session.get('merchant')