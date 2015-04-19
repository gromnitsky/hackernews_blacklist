fub = require './funcbag'
filter = require './filter'

class Sub
    @RANK_OPEN_LABEL = '[-]'
    @RANK_CLOSE_LABEL = '[+]'

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

    toggle: ->
        if @isOpen() then @close() else @open()

    isOpen: ->
        @rank.innerText == Sub.RANK_OPEN_LABEL

    hide: (force = true) ->
        state = if force then "none" else ""

        idx = @rank
        row1nodes = (idx while idx = idx.nextSibling)
        idx.style?.display = state for idx in row1nodes
        @row2.style.display = state

    close: ->
        @hide()
        @rank.innerText = Sub.RANK_CLOSE_LABEL
        @rank.style.cursor = '-webkit-zoom-in'

    open: ->
        @hide false
        @rank.innerText = Sub.RANK_OPEN_LABEL
        @rank.style.cursor = '-webkit-zoom-out'


class HN
    @WARNING_THRESHOLD = 15

    constructor: (@settings) ->
        @home = document.querySelector '.pagetop a'

        @fHostname = new filter.FilterExact false
        @fUserName = new filter.FilterExact false
        @fLinkTitle = new filter.FilterRegexp()

        @fHostname.blackSet @settings['hostname'].join "\n"
        @fUserName.blackSet @settings['username'].join "\n"
        @fLinkTitle.blackSet @settings['linktitle-bl'].join "\n"
        @fLinkTitle.whiteSet @settings['linktitle-wl'].join "\n"

    # Return an array of Sub objects
    getSubs: ->
        items = document.querySelectorAll("tr td[class='title']:first-child")
        r = (new Sub idx for idx in items)

    filter: ->
        count = 0
        for idx in @getSubs()
            console.log "#{idx.getLinkTitle()}, #{idx.getHostname()}, #{idx.getUserName()}"

            if @fHostname.match idx.getHostname()
                @addEL idx
                idx.close()
                count += 1
                idx.rank.title = 'Host name'
                continue

            if @fUserName.match idx.getUserName()
                @addEL idx
                idx.close()
                count += 1
                idx.rank.title = 'User name'
                continue

            if @fLinkTitle.match idx.getLinkTitle()
                @addEL idx
                idx.close()
                count += 1
                idx.rank.title = 'Link title'
                continue

        @warning count if count >= HN.WARNING_THRESHOLD
        # ask background.js to update page icon title
        chrome.extension.sendMessage fub.Message.Creat('statSubs', {'filtered': count})

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
        ]
        @home.innerText = "#{linksFiltered} filtered links? #{t[Math.floor Math.random()*(t.length)]}"

    addEL: (element) ->
        element.rank.addEventListener 'click', (event) ->
            element.toggle()
        , false


# Main
chrome.extension.sendMessage fub.Message.extStorageGetGroup('Filters'), (res) ->
    hn = new HN res
    hn.filter()
