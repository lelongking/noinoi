Wings.defineWidget 'customerDetail',
  events:
    "click .customer-image": (event, template) -> template.find(".customer-image-input").click()
    "change .customer-image-input": (event, template) ->
      instance = @instance
      files = event.target.files
      if files.length > 0
        Storage.CustomerImage.insert files[0], (error, fileObj) ->
          if error
            console.log 'avatar image upload error', error
          else
            Storage.CustomerImage.findOne(instance.image)?.remove()
            Document.Customer.update instance._id, $set: {image: fileObj._id}
    "click .customer-image .clear": (event, template) ->
      Storage.CustomerImage.findOne(@instance.image)?.remove()
      Document.Customer.update @instance._id, $unset: {image: ""}
      event.stopPropagation()

    "click .update-customer": (event, template) ->
      businessOwner  = $(template.find(".businessOwner input")).val()
      phone   = $(template.find(".phone input")).val()
      address = $(template.find(".address input")).val()

      updateCustomer = {}
      updateCustomer.businessOwner  = businessOwner if @instance.businessOwner isnt businessOwner
      updateCustomer.phone   = phone if @instance.phone isnt phone
      updateCustomer.address = address if @instance.address isnt address

      @instance.update(updateCustomer)