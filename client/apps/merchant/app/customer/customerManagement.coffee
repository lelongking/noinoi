Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineApp 'customerManagement',
  created: ->
    self = this
    self.currentCustomer = new ReactiveVar()
    self.autorun ()->
      if customerId = Session.get('mySession')?.currentCustomer
        Wings.SubsManager.subscribe('getCustomerId', customerId)
        self.currentCustomer.set(Schema.customers.findOne(customerId))

  rendered: ->


  helpers:
    currentCustomer: -> Template.instance().currentCustomer.get()
    creationMode: -> Session.get("customerManagementCreationMode")


#  events:
#    "click .excel-customer": (event, template) -> $(".excelFileSource").click()
#    "change .excelFileSource": (event, template) ->
#      if event.target.files.length > 0
#        console.log 'importing'
#        $excelSource = $(".excelFileSource")
#        $excelSource.parse
#          config:
#            complete: (results, file) ->
#              console.log file, results
#              Apps.Merchant.importFileCustomerCSV(results.data)
#        $excelSource.val("")



