root = exports ? this

class root.Cmnt
    @buttonClass = 'hnbl_ToggleButton'
    @buttonOpenLabel = '[-] '
    @buttonCloseLabel = '[+] '

    # identNode is a dom node that contains <img> with a width attribute
    # that designates an ident as an indicator of child relation of a
    # comment.  If width == 0 the comment is a 'root' comment. There can be
    # any number or root comments.
    #
    # The list of identNode's can be obtained via 'td > img[height="1"]'
    # css selector.
    #
    # PG, this is a quite idiotic scheme.
    constructor: (@identNode) ->
        throw new Error 'node is not an image' unless @identNode?.nodeName == "IMG"

        @ident = @identNode.width

        # dude...
        @header = @identNode.parentNode.parentNode.querySelector 'span[class="comhead"]'
        throw new Error "cannot extract comment's header" unless @header
        @headerText = @header.innerText # visual debug

        link = (@header.querySelector 'a[href^="item?id="]') || (@header.querySelector 'a[href*="ycombinator.com/item?id="]')
        @messageID = (link.href.match /id=(\d+)/)[1] if link
        throw new Error "cannot extract comment's messageID for #{@headerText}" unless link

        @username = (@header.querySelector 'a')?.innerText
        throw new Error "cannot extract comment's username for #{@headerText}" unless @username

        @body = @header.parentNode.parentNode.querySelector 'span[class="comment"]'
        throw new Error "cannot extract comment's body" unless @body

        @makeButton()

    makeButton: ->
        throw new Error 'button already exist' if @button # don't make it twice

        @button = document.createElement 'span'
        @button.className = Cmnt.buttonClass

        t = document.createTextNode '?'
        @button.appendChild t
        @buttonOpen()

        # insert a button
        @header.insertBefore @button, @header.firstChild
        console.log 'new button'

    buttonOpen: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText = Cmnt.buttonOpenLabel
        @button.style.cursor = '-webkit-zoom-out'

    buttonClose: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText = Cmnt.buttonCloseLabel
        @button.style.cursor = '-webkit-zoom-in'

    isOpen: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText == Cmnt.buttonOpenLabel

    close: ->
        @bodyHide()
        @buttonClose()

    open: ->
        @bodyHide false
        @buttonOpen()

    # Show if !hide.
    #
    # For 1 paragraph comments, a 'reply' link is a next sibling to
    # @body. All praise to pg!
    bodyHide: (hide = true) ->
        state = if hide then "none" else ""

        reply = @body.nextSibling
        if reply?.nodeName == "P"
            @body.style.display = state
            reply.style.display = state
        else
            @body.style.display = state


class root.Thread
    constructor: (@comments, @memory) ->
        console.error "memory isn't initialized" unless @memory

        for idx, index in @comments
            @addEL(index, idx)
            @collapse idx

    addEL: (index, comment) ->
        throw new Error 'comment w/o a button' unless comment.button

        comment.button.addEventListener 'click', =>
            # collect children
            children = [comment]
            idx = index + 1

            ident = comment.ident
            while @comments[idx]?.ident > ident
                console.log @comments[idx]
                children.push @comments[idx]
                idx += 1

            console.log "comment has #{children.length-1} children"
            # collapse or expand comment and all its children
            if comment.isOpen()
                idx.close() for idx in children
            else
                idx.open() for idx in children

        , false

    # Collapse comment if it is in indexdb. Collapse exactly 1 comment,
    # don't touch its children.
    collapse: (comment) ->
        return unless @memory

        @memory.exist comment.messageID, (exists) =>
            if exists then comment.close() else @memorize comment

    # add comment to indexdb
    memorize: (comment) ->
        return unless @memory
        @memory.add {
            mid: comment.messageID
            username: comment.username
        }


class root.Memory
    @dbName = 'hndl_memory'
    @dbVersion = '1'
    @dbStoreComments = 'comments'

    constructor: (callback) ->
        memory = this
        @nodbCallback = false
        @db = null

        db = webkitIndexedDB.open Memory.dbName

        db.onerror = (event) =>
            console.error 'memory: db error: #{event.target.error}'
            callback null unless @nodbCallback
            @nodbCallback = true

        db.onsuccess = (event) =>
            @db = event.target.result

            if Memory.dbVersion != @db.version
                console.log "memory: db upgrade required"
                setVrequest = @db.setVersion(Memory.dbVersion)
                setVrequest.onsuccess = (event) =>
                    obj_store = @db.createObjectStore Memory.dbStoreComments, {keyPath: 'mid'}
                    obj_store.createIndex 'username', 'username', {unique: false}

                    event.target.transaction.oncomplete = (event) ->
                        console.log "memory: db upgrade completed: #{Memory.dbName} v. #{Memory.dbVersion}"
                        callback memory
            else
                console.log 'memory: db opened'
                callback memory

    add: (object) ->
        t = @db.transaction [Memory.dbStoreComments], "readwrite"
        os = t.objectStore Memory.dbStoreComments
        req = os.put object
        req.onsuccess = ->
            console.log "memory: added #{object.mid} (#{object.username})"

    exist: (mid, callback) ->
        t = @db.transaction [Memory.dbStoreComments], "readonly"
        os = t.objectStore Memory.dbStoreComments
        req = os.get mid
        req.onsuccess = (event) ->
            if event.target.result
                console.log "memory: #{mid} exists: #{req.result.username}"
                callback true
            else
                console.log "memory: no #{mid} exist"
                callback false

# Main
images = document.querySelectorAll('td > img[height="1"]')
new Error '0 comments?' unless images.length > 0

comments = (new Cmnt(idx) for idx in images)
new Memory (memory) ->
    new Thread(comments, memory)
