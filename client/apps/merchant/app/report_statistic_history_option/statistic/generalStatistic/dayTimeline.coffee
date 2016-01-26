Enums = Apps.Merchant.Enums
Wings.defineHyper 'merchantReportDayTimeline',
  created: -> Session.setDefault('totalRevenue', 0)
  helpers:
    timelineMeta: ->
      meta = {}

      profile = Meteor.users.findOne({_id: @creator})?.profile
      if profile?.fullName
        meta.creatorFullName = profile.name ? '?'
        meta.creatorFirstName = Helpers.firstName(meta.creatorFullName)
      else
        meta.creatorFullName = meta.creatorFirstName = Meteor.users.findOne({_id: @creator})?.emails[0].address

      meta.creatorAvatar = AvatarImages.findOne(profile.avatar)?.url() if profile.avatar

      if @timelineType is 'transaction'
        meta.icon = 'icon-money'
        meta.color = if @receivable then 'light-green' else 'red'
        action = if @receivable then 'thu tiền' else 'chi tiền'
        optionalDesc = if @description then "(#{@description})" else ''
        meta.message = "#{meta.creatorFullName} #{action} #{optionalDesc}, giá trị #{accounting.formatNumber(@debtBalanceChange)} VNĐ.
                       Cân bằng nợ mới nhất từ #{accounting.formatNumber(@beforeDebtBalance)} VNĐ, thành
                       #{accounting.formatNumber(@latestDebtBalance)} VNĐ."

      else if @timelineType is 'sale'
        meta.icon = 'icon-tag'
        meta.color = 'green'
        meta.action = 'bán hàng'
        buyerName = Schema.customers.findOne({_id: @buyer})?.name
        meta.message =
          "Bán hàng cho #{buyerName}, giá trị #{accounting.formatNumber(@finalPrice)} VNĐ."

      else if @timelineType is 'return'
        meta.icon = 'icon-reply-outline'
        meta.color = 'blue'
        meta.message = "Trả hàng từ #{meta.creatorFullName} #{accounting.formatNumber(@finalPrice)} VNĐ."

      else if @timelineType is 'import'
        meta.icon = 'icon-download-outline'
        meta.color = 'purple'
        providerName = Schema.providers.findOne({_id: @provider})?.name
        console.log @
        meta.message = "Nhập kho từ #{providerName} #{accounting.formatNumber(@finalPrice)} VNĐ."
      return meta

    timeHook: -> moment(@version.createdAt).format 'HH:mm'

    timelineRecords: ->
      day = new Date()
      startDate = new Date(day.getFullYear(), day.getMonth(), day.getDate())
      toDate    = new Date(day.getFullYear(), day.getMonth(), day.getDate() + 1)

      totalRevenue = 0
      transactions = []
  #    transactions = Schema.transactions.find( {
  #      $and: [
  #        { debtBalanceChange: { $exists: true }}
  #        { beforeDebtBalance: { $exists: true }}
  #        { latestDebtBalance: { $exists: true }}
  #        { debtDate: {$gt: startDate} }
  #        { debtDate: {$lt: toDate} }
  #      ]
  #    }).fetch()
      sales = Schema.orders.find({
        merchant    : merchantId ? Merchant.getId()
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      }).fetch()
      imports = Schema.imports.find({
        merchant    : merchantId ? Merchant.getId()
        importType  : Enums.getValue('ImportTypes', 'success')
      }).fetch()
      returns = Schema.returns.find({
        merchant    : merchantId ? Merchant.getId()
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      }).fetch()

      combined = transactions.concat(sales).concat(imports).concat(returns)
      sorted = _.sortBy combined, (item) ->
        if item.group
          item.timelineType = 'transaction'
        else if item.orderCode
          item.timelineType = 'sale'
        else if item.returnCode
          item.timelineType = 'return'
        else
          item.timelineType = 'import'

        item.version.createdAt


      sorted = _.sortBy sorted, (item) ->
        if item.group
          item.timelineType = 'transaction'
          item.beforeDebtBalance = totalRevenue
          totalRevenue += item.debtBalanceChange
          item.latestDebtBalance = totalRevenue
        else if item.orderCode
          item.timelineType = 'sale'
          item.beforeDebtBalance = totalRevenue
          totalRevenue += item.debtBalanceChange
          item.latestDebtBalance = totalRevenue
        else if item.returnCode
          item.timelineType = 'return'
          item.beforeDebtBalance = totalRevenue
          if item.returnMethods is 0
            totalRevenue -= item.totalCash
          else
            totalRevenue += item.totalCash
          item.latestDebtBalance = totalRevenue
        else
          item.timelineType = 'import'
          item.beforeDebtBalance = totalRevenue
          totalRevenue -= item.debtBalanceChange
          item.latestDebtBalance = totalRevenue

        -item.version.createdAt

      for item, index in sorted
        if index%2
          item.align = ''
          item.arrowAlign = 'arrow'
        else
          item.align = 'alt'
          item.arrowAlign = 'arrow-alt'
      sorted