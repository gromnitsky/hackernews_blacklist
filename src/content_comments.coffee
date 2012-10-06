root = exports ? this

class root.Comment
    @buttonClass = 'hnbl_ToggleButton'
    @buttonOpen = '[-] '
    @buttonClose = '[+] '
    
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
        @button.style.cursor = '-webkit-zoom-out'

        t = document.createTextNode Comment.buttonOpen
        @button.appendChild t

        # insert a button
        @header.insertBefore @button, @header.firstChild
        console.log 'new button'

    addEL: ->
        return unless @button

        @button.addEventListener 'click', ->
            console.log 'yo'
        , false
        
    isRoot: ->
        @ident == 0


# Main
images = document.querySelectorAll('td > img[height="1"]')
new Error '0 comments?' unless images.length > 0

new Comment(idx) for idx in images
