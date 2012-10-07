root = exports ? this

class root.Comment
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

        @body = @header.parentNode.parentNode.querySelector 'span[class="comment"]'
        throw new Error "cannot extract comment's body" unless @body


        @makeButton()

    makeButton: ->
        throw new Error 'button already exist' if @button # don't make it twice

        @button = document.createElement 'span'
        @button.className = Comment.buttonClass

        t = document.createTextNode '?'
        @button.appendChild t
        @buttonOpen()

        # insert a button
        @header.insertBefore @button, @header.firstChild
        console.log 'new button'

    buttonOpen: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText = Comment.buttonOpenLabel
        @button.style.cursor = '-webkit-zoom-out'
        
    buttonClose: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText = Comment.buttonCloseLabel
        @button.style.cursor = '-webkit-zoom-in'

    isOpen: ->
        throw new Error "button doesn't exist" unless @button
        @button.innerText == Comment.buttonOpenLabel

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
        

class Thread
    constructor: (@comments) ->
        @addEL(index, idx) for idx, index in @comments

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
    

# Main
images = document.querySelectorAll('td > img[height="1"]')
new Error '0 comments?' unless images.length > 0

comments = (new Comment(idx) for idx in images)
new Thread(comments)
