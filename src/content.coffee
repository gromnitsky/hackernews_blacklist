# FIXME: remove
document.querySelector('body').style.background = 'gray'

class Message
    constructor: (@name) ->

    encode: (hash) ->
        'msg': @name
        'data': hash

    @Creat: (name, hash) ->
        (new Message(name)).encode hash

extStorageMsgGet = (group, name) ->
    Message.Creat 'extStorage.get', {'group': group, 'name': name}

extStorageMsgGetGroup = (group) ->
    Message.Creat 'extStorage.getGroup', {'group': group}

# Main
chrome.extension.sendMessage extStorageMsgGetGroup('Filters'), (res) ->
    console.log res
