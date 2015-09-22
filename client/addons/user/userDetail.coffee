Wings.defineWidget 'userDetail',
  events:
    "click .user-image": (event, template) -> template.find(".user-image-input").click()
    "change .user-image-input": (event, template) ->
      instance = @instance
      files = event.target.files
      if files.length > 0
        Storage.UserImage.insert files[0], (error, fileObj) ->
          if error
            console.log 'avatar image upload error', error
          else
            Storage.UserImage.findOne(instance.profile.image)?.remove()
            console.log 'before error'
            Document.User.update instance._id, $set: {"profile.image": fileObj._id}
            console.log 'done'
    "click .user-image .clear": (event, template) ->
      Storage.UserImage.findOne(@instance.profile.image)?.remove()
      Document.User.update @instance._id, $unset: {"profile.image": ""}
      event.stopPropagation()