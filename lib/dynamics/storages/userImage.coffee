resizeAndCropCenter = (source, width, height) ->
  source.resize(width, height, '^')
  .gravity('Center').crop(width, height)
  .stream()

storage = new FS.Store.GridFS "userImages",
  transformWrite: (fileObj, readStream, writeStream) ->
    if gm.isAvailable
      gmSource = gm(readStream, fileObj.name())
      resizeAndCropCenter(gmSource, '200', '200').pipe(writeStream)
    else
      readStream.pipe(writeStream)

Module "Storage",
  UserImage: new FS.Collection 'userImages',
    stores: [storage]
    maxSize: 2000000 # 2MB in bytes
    allow:
      contentTypes: ["images/*"]
      extensions: ["png", "jpg", "jpeg"]