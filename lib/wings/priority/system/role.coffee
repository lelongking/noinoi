Module "Wings.Roles.merchantRoles",
  staffSale   : -> ['merchant-staff-sale']
  managerSale : -> ['merchant-manage-sale', @managerSale()]

  staffWarehouse   : -> ['merchant-staff-warehouse']
  managerWarehouse : -> ['merchant-manage-warehouse', @managerWarehouse()]

  staffAccounting   : -> ['merchant-manage-accounting']
  managerAccounting : -> ['merchant-manage-accounting', @staffAccounting()]

  staffDelivery   : -> ['merchant-staff-delivery']
  managerDelivery : -> ['merchant-manage-delivery', @staffDelivery()]

  staffAdmin   : -> ['merchant-staff-admin', @managerSale(), @managerWarehouse(), @managerAccounting(), @managerDelivery()]
  managerAdmin : -> ['merchant-manager-admin', @staffAdmin()]

Module "Wings.Roles",
  foundRoles: (roles = [])->
    newRoles = []
    for role in roles
      newRole = @merchantRoles[role]
      found = if typeof newRole is 'function' then newRole() else newRole
      newRoles.push(found) if found
    newRoles = _.uniq(_.flatten([newRoles]))

  userIsInMerchantRole: (user, roles = []) ->
    if !_.isArray(roles) then roles = [roles]
    if !user or roles.length is 0 then return false
    Roles.userIsInRole(user, foundRoles(roles))

  addUsersToRoles: (user, roles) ->
  isCreateMerchantUser: (user)-> true
