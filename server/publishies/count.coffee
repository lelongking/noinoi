Meteor.publish null, -> Counts.publish @, 'branch', Document.Branch.find(); return
Meteor.publish null, -> Counts.publish @, 'product', Document.Product.find(); return
Meteor.publish null, -> Counts.publish @, 'customer', Document.Customer.find(); return
Meteor.publish null, -> Counts.publish @, 'user', Meteor.users.find({creator: {$exists: true}}); return
Meteor.publish null, -> Counts.publish @, 'order', Document.Order.find(); return
Meteor.publish null, -> Counts.publish @, 'import', Document.Import.find(); return
Meteor.publish null, -> Counts.publish @, 'plan', Document.Plan.find(); return