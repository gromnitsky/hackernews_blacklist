fub = require './funcbag'

# Return an array from a string str.
exports.parseRawData = (str) ->
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
        try
            return false if @useWhite && @matchInList(val, @whitelist)
            @matchInList val, @blacklist
        catch e
            console.error "match error: #{e.message}" unless @quiet
            return false

class exports.FilterRegexp
    constructor: (@useWhite = true) ->
        @quiet = false
    
        @blacklist = []
        @whitelist = []

    matchInList: (val, inList) ->
        for idx in inList
            re = new RegExp idx, 'i'
            return true if val.match re
        false

    listSet: (str) ->
        exports.parseRawData str

    listGet: (list) ->
        list.join "\n"

fub.include exports.FilterRegexp, FilterInterface

class exports.FilterExact
    constructor: (@useWhite = true) ->
        @quiet = false
    
        @blacklist = {}
        @whitelist = {}

    matchInList: (val, inList) ->
        val of inList

    listSet: (str) ->
        r = {}
        r[idx] = 1 for idx in (exports.parseRawData str)
        r

    listGet: (list) ->
        r = []
        r.push key for key, val of list
        r.join "\n"

fub.include exports.FilterExact, FilterInterface
