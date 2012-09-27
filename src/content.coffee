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
            @rank.style.cursor = '-webkit-zoom-out'
        else
            # collapse this item
            idx.style.display = 'none' for idx in row1nodes
            @row2.style.display = 'none'

            @rank.innerText = '[+]'
            @rank.style.cursor = '-webkit-zoom-in'

class HN
    @warningThreshold = 10
    
    constructor: ->
        @home = document.querySelector '.pagetop a'

    # Return an array of Sub objects
    getSubs: ->
        r = []
        items = document.querySelectorAll("tr td[class='title']:first-child")
        r.push (new Sub idx) for idx in items
        r

    filter: ->
        for idx, count in @getSubs()
            console.log "#{idx.getTitleLink()}, #{idx.getHostname()}, #{idx.getUserName()}"
            @toggleItem idx
            idx.toggleCollapse()

        @warning count if count >= HN.warningThreshold
        chrome.extension.sendMessage Message.Creat('stat', {'filtered': count})

    warning: (linksFiltered) ->
        t = [
            "Could it be, could it be that you're joking with me?"
            "Due to lack of interest tomorrow is canceled."
            "A harsh day, dude?"
            "The filter goes wild."
            "Relax, dude."
            "Take a break, dude."
            "Dude, this is ridiculous."
            "C'mon dude, that's not possible."
            "Bwaa!"
            "I don't know, dude."
            "Get up your sorry ass, dude."
            "In good old days HN wasn't so bad."
            "Has somebody died again?"
            "Who got hit and who hit first?"
            "Who was bad and who got worse?"
            "Who got caught up in the life?"
            "Who went down and who got higher?"
            "Who went left and who was right?"
            "Who went out on a mischief night?"
            ]
        @home.innerText = "#{linksFiltered} filtered links? #{t[Math.floor Math.random()*(t.length)]}"

    toggleItem: (element) ->
        element.rank.addEventListener 'click', ->
            element.toggleCollapse()
        , false
        

# Main
chrome.extension.sendMessage extStorageMsgGetGroup('Filters'), (res) ->
    hn = new HN()
    hn.filter()
    console.log res
