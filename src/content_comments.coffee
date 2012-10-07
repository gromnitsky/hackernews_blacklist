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
        @header = @identNode.parentNode.parentNode.querySelector('span[class="comhead"]')
        throw new Error 'cannot extract comment header' unless @header
        @body = @header.parentNode.parentNode.querySelector('span[class="comment"]')
        throw new Error 'cannot extract comment body' unless @body

        @makeButton()
        @addEL()

    makeButton: ->
        return if @button # don't make it twice

        @button = document.createElement 'span'
        @button.className = Comment.buttonClass

        t = document.createTextNode '?'
        @button.appendChild t
        @buttonOpen()

        # insert a button
        @header.insertBefore @button, @header.firstChild
        console.log 'new button'

    buttonOpen: ->
        return unless @button
        @button.innerText = Comment.buttonOpenLabel
        @button.style.cursor = '-webkit-zoom-out'
        
    buttonClose: ->
        return unless @button
        @button.innerText = Comment.buttonCloseLabel
        @button.style.cursor = '-webkit-zoom-in'

    addEL: ->
        return unless @button

        @button.addEventListener 'click', =>
            @toggleCollapseWithChilds()
        , false

    toggleCollapseWithChilds: ->
        # FIXME
        @toggleCollapse()

    toggleCollapse: ->
        return unless @button

        if @button.innerText == Comment.buttonOpenLabel
            # collapse it
            @bodyHide()
            @buttonClose()
        else
            # expand it
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
        
    isRoot: ->
        @ident == 0


# Main
images = document.querySelectorAll('td > img[height="1"]')
new Error '0 comments?' unless images.length > 0

new Comment(idx) for idx in images
