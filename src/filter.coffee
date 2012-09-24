root = exports ? this

class root.Filter
    constructor: (@type, @useWhite = true) ->
        if @type != 'exact' && @type != 'regexp'
            throw new Error "type must be 'exact' or 'regexp'"

        @blacklist = []
        @whitelist = []

    # return an array from a string str
    parseRawData: (str) ->
        arr = str.split "\n"
        r = []
        for idx in arr
            v = idx.trim()
            r.push v if v.length != 0
        r

    # override while-list
    whiteSet: (str) ->
        @whitelist = @parseRawData str

    whiteGet: ->
        @whitelist.join "\n"

    # override black-list
    blackSet: (str) ->
        @blacklist = @parseRawData str

    blackGet: ->
        @blacklist.join "\n"

    _matchInList: (val, inList) ->
        (return true if @_matchVal idx, val) for idx in inList
        false

    _matchVal: (pattern, val) ->
        if @type == 'regexp'
            val.match pattern
        else
            val == pattern

    match: (val) ->
        return false if @useWhite && @_matchInList(val, @whitelist)
        @_matchInList val, @blacklist
