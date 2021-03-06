Wings.defineWidget 'salePrinter',
  helpers:
    merchant: -> Session.get('merchant')
    dayOfWeek: -> moment(Session.get('realtime-now')).format("dddd")
    timeDMY: -> moment(Session.get('realtime-now')).format("DD/MM/YYYY")
    timeHM: -> moment(Session.get('realtime-now')).format("hh:mm")
    timeS: -> moment(Session.get('realtime-now')).format("ss")
    soldPrice: -> @price - (@price * @discountPercent)/100
    discountVisible: -> @discountPercent > 0

  events:
    "click .print-button": -> window.print()