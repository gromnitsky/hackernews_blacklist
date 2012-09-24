document.querySelector('body').style.background = 'yellow'

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

chrome.extension.sendMessage extStorageMsgGet('test', 'foo'), (res) ->
    console.log res

chrome.extension.sendMessage extStorageMsgGetGroup('test'), (res) ->
    console.log res
