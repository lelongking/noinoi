Module "Wings.Document",
  register: (pluralName, singularName, defination = {}) ->
    Document[singularName] = document = new Meteor.Collection pluralName,
      transform: (doc) ->
        doc.Document = singularName
        defination.transform?(doc)
        doc

    Model[singularName]  = model  = defination
    model.document = document

Module 'Document',
  ApiNode         : new Meteor.Collection 'apiNodes'
  ApiMachineLeaf  : new Meteor.Collection 'apiMachineLeaves'
  ApiHumanLeaf    : new Meteor.Collection 'apiHumanLeaves'

#  Channel         : new Meteor.Collection 'channels'
#  Message         : new Meteor.Collection 'messages'
