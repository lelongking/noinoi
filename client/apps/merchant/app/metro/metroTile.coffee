Wings.defineApp 'metroTile',
  created: ->
#    console.log 'metroTile create'

#    self = this
#    self.ready = new ReactiveVar()
#    self.autorun ()->
#      if self.appCount
#        handle = Wings.SubsManager.subscribe(self.appCount)
#        self.ready.set(handle.ready())

  rendered: ->
#    console.log 'metroTile render'

  helpers:
    getCount: -> if Counts.has(@appCount) then Counts.get(@appCount) else undefined