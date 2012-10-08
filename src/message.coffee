root = exports ? this

# Message builder for content scripts.
#
# Example:
#
# root = exports ? this
# msg = require?('./message') || root
# chrome.extension.sendMessage msg.Message.Creat('statSubs', {'filtered': count})
#
# Btw, 'Creat' is not a typo.
class root.Message
    constructor: (@name) ->

    encode: (hash) ->
        'msg': @name
        'data': hash

    @Creat: (name, hash) ->
        (new Message(name)).encode hash
