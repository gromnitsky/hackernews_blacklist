root = exports ? this

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

class root.Sub
    # rank -- a dom element (tr) that represents a sub 'anchor'
    constructor: (@rank) ->
        @row1 = @rank.parentNode
        @row2 = @row1.nextSibling

    getLink: ->
        @row1.querySelectorAll('a')[1] || @row1.querySelector('a')

    getLinkTitle: ->
        @getLink().innerText

    getHostname: ->
        # bwaa! no need for uri parsing!
        @getLink().hostname
                
    getUserName: ->
        @row2.querySelector('a')?.innerText || ''

    # replace rank with '[-]' or '[+]' & toggle
    toggleCollapse: ->
        idx = @rank
        row1nodes = (idx while idx = idx.nextSibling)

        if @rank.innerText.match /^\[\+]/
            # expand this item
            idx.style.display = '' for idx in row1nodes
            @row2.style.display = ''

            @rank.innerText = "[-]"
            @rank.style.cursor = '-webkit-zoom-out'
        else
            # collapse this item
            idx.style.display = 'none' for idx in row1nodes
            @row2.style.display = 'none'

            @rank.innerText = "[+]"
            @rank.style.cursor = '-webkit-zoom-in'

class root.HN
    @warningThreshold = 10
    
    constructor: (@settings) ->
        @home = document.querySelector '.pagetop a'

        @fHostname = new FilterExact false
        @fUserName = new FilterExact false
        @fLinkTitle = new FilterRegexp()

        @fHostname.blackSet @settings['hostname'].join "\n"
        @fUserName.blackSet @settings['username'].join "\n"
        @fLinkTitle.blackSet @settings['linktitle-bl'].join "\n"
        @fLinkTitle.whiteSet @settings['linktitle-wl'].join "\n"

    # Return an array of Sub objects
    getSubs: ->
        r = []
        items = document.querySelectorAll("tr td[class='title']:first-child")
        r.push (new Sub idx) for idx in items
        r

    filter: ->
        count = 0
        for idx in @getSubs()
            console.log "#{idx.getLinkTitle()}, #{idx.getHostname()}, #{idx.getUserName()}"
            if @fHostname.match idx.getHostname()
                @addEL idx
                idx.toggleCollapse()
                count += 1
                idx.rank.title = 'Host name'

            if @fUserName.match idx.getUserName()
                @addEL idx
                idx.toggleCollapse()
                count += 1
                idx.rank.title = 'User name'

            if @fLinkTitle.match idx.getLinkTitle()
                @addEL idx
                idx.toggleCollapse()
                count += 1
                idx.rank.title = 'Link title'

        @warning count if count >= HN.warningThreshold
        # ask background.js to update page icon title
        chrome.extension.sendMessage Message.Creat('stat', {'filtered': count})

    warning: (linksFiltered) ->
        t = [
            "Could it be, could it be that you're joking with me?"
            "A harsh day, dude?"
            "The filter goes wild."
            "Relax, dude."
            "Take a break, dude."
            "Dude, this is ridiculous."
            "C'mon, dude."
            "Bwaa!"
            "I don't know, dude."
            "Get up your sorry ass, dude."
            "In good old days HN wasn't so bad."
            "Has somebody died again?"
            ""
            ]
        @home.innerText = "#{linksFiltered} filtered links? #{t[Math.floor Math.random()*(t.length)]}"

    addEL: (element) ->
        element.rank.addEventListener 'click', ->
            element.toggleCollapse()
        , false
        

# Main
chrome.extension.sendMessage extStorageMsgGetGroup('Filters'), (res) ->
#    console.log res
    hn = new HN res
    hn.filter()
