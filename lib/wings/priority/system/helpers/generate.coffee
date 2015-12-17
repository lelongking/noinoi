Module 'Wings.Helper',
  GenerateBarcode: (prefix="0", length=10) ->
    prefix += Math.floor(Math.random() * 10) for i in [0...length]
    prefix

  GenerateCode: (number = 0, sub = 'KH', maxLength = 7) ->
    code = Number(number); code = 0 if code is NaN; code +=1
    lengthCode = (sub + code.toString()).length
    middle = ''; range = maxLength - lengthCode
    (middle += '0' for i in [1..range]) if range > 0
    customerCode = sub + middle + code.toString()
    return customerCode


  checkAndGenerateCode: (number = 0, listCodes = [], sub = 'KH', maxLength = 7) ->
    generateCode = true
    while generateCode
      customerCode = Wings.Helper.GenerateCode(number, sub, maxLength)
      codeIndexOf  = _.indexOf(listCodes, customerCode)
      generateCode = codeIndexOf > -1
      number++
    return customerCode