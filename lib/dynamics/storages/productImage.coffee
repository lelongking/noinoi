resizeAndCropCenter = (source, width, height) ->
  source.resize(width, height, '^')
  .gravity('Center').crop(width, height)
  .stream()

storage = new FS.Store.GridFS "productImages",
  transformWrite: (fileObj, readStream, writeStream) ->
    if gm.isAvailable
      gmSource = gm(readStream, fileObj.name())
      resizeAndCropCenter(gmSource, '100', '100').pipe(writeStream)
    else
      readStream.pipe(writeStream)

Module "Storage",
  ProductImage: new FS.Collection 'productImages',
    stores: [storage]
    maxSize: 2000000 # 2MB in bytes
    allow:
      contentTypes: ["images/*"]
      extensions: ["png", "jpg", "jpeg"]