# An DB abstraction layer upon Opera widget.preferences object.
# See also http://www.w3.org/TR/webstorage/#the-storage-interface
#
# The same goes for Chrome's localStorage & Firefox's, but who cares
# about Firefox.

root = exports ? this

class root.ExtStorage

    constructor: ->
        @db = widget?.preferences || localStorage || {}

    raw: ->
        @db
    
    _getGroup: (group) ->
        try
            g = JSON.parse @db[group]
        catch e
            return {}
        g || {}
                        
    get: (group, name) ->
        g = @_getGroup group
        if g[name] == undefined then null else g[name]

    set: (group, name, value) ->
        g = @_getGroup group
        g[name] = value
        @db[group] = JSON.stringify g

    clean: ->
        if widget? || localStorage?
            @db.clear()
        else
            delete @db[k] for k,v of @db

    size: ->
        (Object.keys @db).length

    # Useful factory method
    @Get: (group, name) ->
        (new root.ExtStorage()).get group, name

    @Set: (group, name, value) ->
        (new root.ExtStorage()).set group, name, value

    @GetGroup: (group) ->
        (new root.ExtStorage())._getGroup group
