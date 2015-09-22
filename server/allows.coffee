Document.Branch.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.Product.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true #userId is doc.creator
  remove: (userId, doc) -> true

Document.Import.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true #userId is doc.creator
  remove: (userId, doc) -> true

Document.Customer.allow
  insert: (userId, doc) -> true #userId is doc.creator
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.Order.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.Delivery.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.Staff.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.News.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.PriceBook.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Document.System.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

Storage.ProductImage.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fieldNames, modifier) -> true
  remove: (userId, doc) -> true
  download: (userId)-> true

Storage.UserImage.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fieldNames, modifier) -> true
  remove: (userId, doc) -> true
  download: (userId)-> true

Storage.CustomerImage.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fieldNames, modifier) -> true
  remove: (userId, doc) -> true
  download: (userId)-> true