lemon.defineWidget Template.saleReview,
  helpers:
    dayOfWeek: -> moment(Session.get('currentOrderManagerSale')?.version.createdAt).format("dddd")
    timeDMY: -> moment(Session.get('currentOrderManagerSale')?.version.createdAt).format("DD/MM/YYYY")
    timeHM: -> moment(Session.get('currentOrderManagerSale')?.version.createdAt).format("hh:mm")
    timeS: -> moment(Session.get('currentOrderManagerSale')?.version.createdAt).format("ss")
    soldPrice: -> @price - (@price * @discountPercent)/100
    discountVisible: -> @discountPercent > 0

  events:
    "click .print-button": -> window.print()