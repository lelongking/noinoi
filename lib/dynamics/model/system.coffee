Wings.Document.register 'systems', 'System', class System
  @Initialize: ->
    @document.remove({})
    @document.insert
      Version: "1.0.0"
      Summaries:
        ProductCount      : 0
        CustomerCount     : 0
        StaffCount        : 0
        PriceBookCount    : 0
        OrderCount        : 0