root = exports ? this
mixin = require?('./mixins') || root

# Return an array from a string str.
root.parseRawData = (str) ->
    arr = str.split "\n"
    r = []
    for idx in arr
        v = idx.trim()
        r.push v if v.length != 0
    r

FilterInterface = 
    whiteSet: (str) ->
        @whitelist = @listSet str

    whiteGet: ->
        @listGet @whitelist

    blackSet: (str) ->
        @blacklist = @listSet str

    blackGet: ->
        @listGet @blacklist

    match: (val) ->
        return false if @useWhite && @matchInList(val, @whitelist)
        @matchInList val, @blacklist

class root.FilterRegexp extends mixin.Module
    @include FilterInterface
    
    constructor: (@useWhite = true) ->
        @blacklist = []
        @whitelist = []

    matchInList: (val, inList) ->
        (return true if val.match idx) for idx in inList
        false

    listSet: (str) ->
        root.parseRawData str

    listGet: (list) ->
        list.join "\n"

class root.FilterExact extends mixin.Module
    @include FilterInterface
    
    constructor: (@useWhite = true) ->
        @blacklist = {}
        @whitelist = {}

    matchInList: (val, inList) ->
        val of inList

    listSet: (str) ->
        r = {}
        r[idx] = 1 for idx in (root.parseRawData str)
        r

    listGet: (list) ->
        r = []
        r.push key for key, val of list
        r.join "\n"
