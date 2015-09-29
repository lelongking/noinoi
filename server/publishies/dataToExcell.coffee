fullBorder =
  top: {style:"thin"}
  left: {style:"thin"}
  bottom: {style:"thin"}
  right: {style:"thin"}

Enums = Apps.Merchant.Enums
Excel       = Meteor.npmRequire('exceljs')
express     = Meteor.npmRequire('express')
path        = Meteor.npmRequire('path')
pathResolve = path.resolve('.')


#get path of Public
if pathResolve.indexOf('.meteor') > 0
  #is Client Folder Public
  publicPath = pathResolve.split('.meteor')[0] + 'public/'
else
  #is Server Folder Public
  publicPath = pathResolve.split('server')[0] + 'web.browser/app/'


Express = ->
  app = express()
  WebApp.connectHandlers.use Meteor.bindEnvironment(app)
  app
app = Express()


app.get '/download/customer/:id', (req, res) ->
  if customer = Schema.customers.findOne(req.params.id)
    #newFile Excel
    workbook  = new Excel.Workbook()
    worksheet = workbook.addWorksheet("cong_no")

    #getData of Order and Return
    orderLists  = getOrderLists(customer._id)
    returnLists = getReturnLists(customer._id)

    #writeData to Excel
    beginRowData = 12
    workbook.xlsx.readFile(publicPath+'template/TBD.xlsx').then ->
      worksheet = workbook.getWorksheet("cong_no")

      resetValueHead(worksheet)
      worksheet.getColumn(i).numFmt = "#,##0" for i in [6,8,9,10,11]


      worksheet.getColumn(index).alignment = { vertical: "middle", horizontal: "center" } for index in [6..9]


      #addData OrderDetail
      beginRowData = addDataInExcelCustomer(worksheet, orderLists, beginRowData)

      #add Head Table Return
      getRow = worksheet.getRow(beginRowData)
      returnHead = []; returnHead[2] = 'HÀNG TRẢ VỀ'; getRow.values = returnHead
      getRow.getCell(2).border = fullBorder
      worksheet.mergeCells('B' + beginRowData + ':K' + beginRowData)
      beginRowData +=1

      #addData ReturnDetail
      beginRowData = addDataInExcelCustomer(worksheet, returnLists, beginRowData)


      #addFooter
      keys = [
        undefined
        "Nợ tồn đầu kỳ:"
        "Phát sinh trong kỳ:"
        "Thu nợ trong kỳ:"
        "Trừ hàng trả về:"
        "Nợ cuối kỳ:"
      ]
      values = [
        "VNĐ"
        customer.beginCash
        customer.debtCash
        customer.paidCash - customer.loanCash
        customer.returnCash
        customer.totalCash
      ]

      for i in [0..5]
        worksheet.getCell('E'+beginRowData).value = keys[i]
        worksheet.getCell('F'+beginRowData).value = values[i]
        worksheet.getCell('F'+beginRowData).alignment = { vertical: "middle", horizontal: "right" }
        worksheet.mergeCells('F'+beginRowData+':G'+beginRowData)
        beginRowData+=1


      fileName = 'template/cong_no.xlsx'
      workbook.xlsx.writeFile(publicPath+ fileName).then ->
        path = publicPath+ fileName
        res.download path

app.get '/download/order/:id', (req, res) ->
  console.log req.params.id
  if order = Schema.orders.findOne(req.params.id)
    for detail, index in order.details
      if product = Schema.products.findOne(detail.product)
        order.details[index].array = [
          index+1
          product.name
          product.unitName()
          if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0
          detail.basicQuantity
#          detail.price
#          detail.price * detail.basicQuantity
        ]

    workbook  = new Excel.Workbook()
    workbook.xlsx.readFile(publicPath+'template/PXK.xlsx').then ->
      worksheet = workbook.getWorksheet("xuat_kho")
      resetValueHead(worksheet)
      worksheet.getColumn(i).numFmt = "#,##0" for i in [4..7]

      #writeData to Excel
      beginRowData = 14
      beginRowData = addDataInExcelOrder(worksheet, [order], beginRowData, 1, 8)


      #add Footer
      worksheet.getCell('A'+beginRowData).value = '(Mọi thắc mắc về hàng hóa, vui lòng liên hệ số điện thoại 08.6295.9999 trong vòng 03 ngày từ ngày nhận hàng)'
      worksheet.getCell('A'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }
      worksheet.mergeCells('A'+beginRowData+':H'+beginRowData)
      beginRowData += 1

      worksheet.getCell('B'+beginRowData).value = 'Địa chỉ chành:'
      beginRowData +=1

      worksheet.mergeCells('G'+beginRowData+':H'+beginRowData)
      beginRowData += 1

      worksheet.getCell('B'+beginRowData).value     = 'Người nhận hàng'
      worksheet.getCell('B'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }

      worksheet.getCell('C'+beginRowData).value = 'Kiểm soát 1'
      worksheet.getCell('C'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }
      worksheet.mergeCells('C'+beginRowData+':D'+beginRowData)

      worksheet.getCell('E'+beginRowData).value = 'Kiểm soát 2'
      worksheet.getCell('E'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }

      worksheet.getCell('G'+beginRowData).value = 'Thủ kho'
      worksheet.getCell('G'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }

      worksheet.getCell('H'+beginRowData).value = 'Người lập phiếu'
      worksheet.getCell('H'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }
      beginRowData += 1


      fileName = 'template/xuat_kho.xlsx'
      workbook.xlsx.writeFile(publicPath+ fileName).then ->
        path = publicPath+ fileName
        res.download path



addExcelHead = (worksheet) ->
  worksheet.getCell("A1").value = "CÔNG TY CỔ PHẦN CHÂU Á THÁI BÌNH DƯƠNG"
  worksheet.mergeCells("A1:F1")
  worksheet.getCell("A2").value = "60 Trần Đại Nghĩa, Ninh Kiều, Cần Thơ"
  worksheet.mergeCells("A2:F2")
  worksheet.getCell("A3").value = "BẢNG ĐỐI CHIẾU CÔNG NỢ"
  worksheet.mergeCells("A3:O3")
  worksheet.getCell("A4").value = "(từ ngày 01/03/2015 đến ngày 31/08/2015)"
  worksheet.mergeCells("A4:O4")

  worksheet.getCell("A5").value = "Kính gởi Khách hàng: "
  worksheet.mergeCells("A5:D5")
  worksheet.getCell("I5").value = "Địa chỉ: "
  worksheet.mergeCells("I5:M5")


  worksheet.getCell("A6").value = 'Trước hết, CÔNG TY CỐ PHẦN CHÂU Á THÁI BÌNH DƯƠNG xin được gửi tới Quý khách hàng lời cảm ơn chân thành vì sự ủng hộ nhiệt tình '
  worksheet.mergeCells("A6:M6")
  worksheet.getCell("A7").value = 'dành cho Công ty chúng tôi trong thời gian qua.'
  worksheet.mergeCells("A7:M7")
  worksheet.getCell("A8").value = 'Từ ngày 01/03/2015 đến ngày 31/08/2015, CÔNG TY CỐ PHẦN CHÂU Á THÁI BÌNH DƯƠNG đã cung cấp cho Quý đại lý các mặt hàng với'
  worksheet.mergeCells("A8:M8")
  worksheet.getCell("A9").value = 'chi tiết như sau:'
  worksheet.mergeCells("A9:M9")


getOrderLists = (customerId) ->
  orderIndex = 1
  Schema.orders.find({
    buyer      : customerId
    orderType  : Enums.getValue('OrderTypes', 'success')
    orderStatus: Enums.getValue('OrderStatus', 'finish')
  }).map((order) ->
    for detail, index in order.details
      if product = Schema.products.findOne(detail.product)
        fullName     = product.name.split('-')
        productName  = fullName[0].replace(/^\s*/, "").replace(/\s*$/, "")
        productSkull = if fullName[1] then fullName[1].replace(/^\s*/, "").replace(/\s*$/, "") else ""
        unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0

        if index is 0
          detailIndex = orderIndex
          orderIndex += 1
        else
          detailIndex = ''

        order.details[index].array = [
          undefined
          detailIndex
          order.orderCode
          new Date(order.successDate)
          productName.toString()
          productSkull
          product.unitName()
          unitQuantity
          detail.basicQuantity
          detail.price
          detail.price * detail.basicQuantity
        ]
    order
  )

getReturnLists = (customerId)->
  returnIndex = 1
  Schema.returns.find({
    owner       : customerId
    returnType  : Enums.getValue('ReturnTypes', 'customer')
    returnStatus: Enums.getValue('ReturnStatus', 'success')
  }).map((currentReturn) ->
    for detail, index in currentReturn.details
      if product = Schema.products.findOne(detail.product)
        fullName     = product.name.split('-')
        productName  = fullName[0].replace(/^\s*/, "").replace(/\s*$/, "")
        productSkull = if fullName[1] then fullName[1].replace(/^\s*/, "").replace(/\s*$/, "") else ""
        unitQuantity = if product.units[1] then Math.floor(detail.basicQuantity/product.units[1].conversion) else 0
        if index is 0
          detailIndex = returnIndex
          returnIndex += 1
        else
          detailIndex = ''

        currentReturn.details[index].array = [
          undefined
          detailIndex
          currentReturn.returnCode
          new Date(currentReturn.successDate)
          productName.toString() if productName
          productSkull
          product.unitName()
          unitQuantity
          detail.basicQuantity
          detail.price
          detail.price * detail.basicQuantity
        ]
    currentReturn
  )


addDataInExcelCustomer = (worksheet, dataLists, beginRowData, quantities = 0, totalPrice = 0) ->
  #add detail
  for item in dataLists
    for detail in item.details
      getRow = worksheet.getRow(beginRowData)
      for value, index in detail.array
        getRow.getCell(index+1).value  = value
        getRow.getCell(index+1).border = fullBorder


        quantities += value if index+1 is 8
        totalPrice += value if index+1 is 11
      beginRowData += 1

  #add sumDetail
  getRow = worksheet.getRow(beginRowData)
  for index in [2..11]
    if index is 2 then       getRow.getCell(index).value  = "TỔNG"
    else if index is 8 then  getRow.getCell(index).value  = quantities
    else if index is 11 then getRow.getCell(index).value  = totalPrice
    else                     getRow.getCell(index).value  = ''
    getRow.getCell(index).border = fullBorder

  #set alignment sumDetail
  worksheet.getCell('B'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }
  worksheet.mergeCells('B'+beginRowData+':G'+beginRowData)
  beginRowData += 1

  beginRowData


addDataInExcelOrder = (worksheet, dataLists, beginRowData, columnStart, columnEnd) ->
  #add detail
  quantities = 0; basicQuantities = 0; totalPrice = 0
  for item in dataLists
    for detail in item.details
      getRow = worksheet.getRow(beginRowData)
      for column in [columnStart..columnEnd]
        getRow.getCell(column).value  = if detail.array[column-1] then detail.array[column-1] else ''
        getRow.getCell(column).border = fullBorder

        if column is 4 then basicQuantities += detail.array[column-1]
        else if column is 5 then quantities += detail.array[column-1]
        else if column is 7 then totalPrice += detail.array[column-1]
      beginRowData += 1

  #add sumDetail
  getRow = worksheet.getRow(beginRowData)
  for column in [columnStart..columnEnd]
    if column is 2 then      getRow.getCell(column).value  = "TỔNG"
    else if column is 4 then getRow.getCell(column).value  = basicQuantities
    else if column is 5 then getRow.getCell(column).value  = quantities
#    else if index is 7 then getRow.getCell(index).value  = totalPrice
    else                    getRow.getCell(column).value  = ''
    getRow.getCell(column).border = fullBorder

  #set alignment sumDetail
  worksheet.getCell('B'+beginRowData).alignment = { vertical: "middle", horizontal: "center" }
  beginRowData += 1

  beginRowData



resetValueHead = (worksheet) ->
  worksheet.eachRow (row, rowNumber) ->
    getRow = worksheet.getRow(rowNumber)
    for value, index in worksheet.getRow(rowNumber).values
      getRow.getCell(index+1).value  = undefined
      getRow.getCell(index+1).border = {}