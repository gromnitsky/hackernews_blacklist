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

class Sub
    # rank -- a dom element (tr) that represents a sub 'anchor'
    constructor: (@rank) ->
        @row1 = @rank.parentNode
        @row2 = @row1.nextSibling

    getTitleLink: ->
        @row1.querySelectorAll('a')[1].innerText

    getHostname: ->
        # bwaa! no need for uri parsing!
        @row1.querySelectorAll('a')[1].hostname
                
    getUserName: ->
        @row2.querySelector('a').innerText

    # replace rank with '[-]' or '[+]' & toggle
    toggleCollapse: ->
        idx = @rank
        row1nodes = (idx while idx = idx.nextSibling)

        if @rank.innerText.match /^\[\+]/
            # expand this item
            idx.style.display = '' for idx in row1nodes
            @row2.style.display = ''
            @rank.innerText = '[-]'
        else
            # collapse this item
            idx.style.display = 'none' for idx in row1nodes
            @row2.style.display = 'none'
            @rank.innerText = '[+]'
        

class NH
    constructor: ->

    # Return an array of Sub objects
    getSubs: ->
        r = []
        items = document.querySelectorAll("tr td[class='title']:first-child")
        r.push (new Sub idx) for idx in items
        r

    filter: ->
        for idx in @getSubs()
            console.log "#{idx.getTitleLink()}, #{idx.getHostname()}, #{idx.getUserName()}"
            @toggleItem idx

    toggleItem: (element) ->
        element.rank.addEventListener 'click', ->
            element.toggleCollapse()
        , false
        

# Main
chrome.extension.sendMessage extStorageMsgGetGroup('Filters'), (res) ->
    hn = new NH()
    hn.filter()
    console.log res
