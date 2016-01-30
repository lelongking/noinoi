Enums = Apps.Merchant.Enums
Meteor.methods
  reCalculateCustomerInterestAmount: (customerId)->
    user     = Meteor.users.findOne({_id: @userId})
    merchant = Schema.merchants.findOne({_id: user.profile.merchant}) if user?.profile
    customer = Schema.customers.findOne({_id: customerId, merchant: merchant._id}) if merchant

    if customer
      interestRates = merchant.interestRates

      customer.initialInterestRate = (interestRates.initial ? 0)  if customer.initialInterestRate is undefined
      customer.saleInterestRate = (interestRates.sale ? 0)  if customer.saleInterestRate is undefined

      interestPerDay = (customer.initialAmount ? 0)/100 * (customer.initialInterestRate ? 0)/30
      interestDays   = moment().diff(customer.initialStartDate ? new Date(), 'days')
      interestCash   = interestPerDay*interestDays

      Schema.orders.find(
        buyer                   : customer._id
        orderType               : Enums.getValue('OrderTypes', 'success')
        orderStatus             : Enums.getValue('OrderStatus', 'finish')
        'details.interestRate'  : true
      ).forEach(
        (order)->
          totalCash = 0
          (totalCash += detail.price * detail.basicQuantity if detail.interestRate) for detail in order.details

          interestPerDay = totalCash/100 * (customer.saleInterestRate ? 0)/30
          interestDays   = moment().endOf('days').diff(moment(order.successDate ? new Date()).startOf('days'), 'days')
          interestCash  += interestPerDay*interestDays
          console.log interestDays
      )
      Schema.customers.update customer._id, $set:{interestAmount: parseInt(interestCash) ? 0}