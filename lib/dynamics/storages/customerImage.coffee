resizeAndCropCenter = (source, width, height) ->
  source.resize(width, height, '^')
  .gravity('Center').crop(width, height)
  .stream()

storage = new FS.Store.GridFS "customerImages",
  transformWrite: (fileObj, readStream, writeStream) ->
    if gm.isAvailable
      gmSource = gm(readStream, fileObj.name())
      resizeAndCropCenter(gmSource, '200', '200').pipe(writeStream)
    else
      readStream.pipe(writeStream)

Module "Storage",
  CustomerImage: new FS.Collection 'customerImages',
    stores: [storage]
    maxSize: 2000000 # 2MB in bytes
    allow:
      contentTypes: ["images/*"]
      extensions: ["png", "jpg", "jpeg"]