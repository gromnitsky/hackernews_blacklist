root = exports ? this

# https://github.com/jashkenas/coffee-script/issues/218#issuecomment-146909
root.extend = (obj, mixin) ->
    obj[name] = method for name, method of mixin

root.include = (klass, mixin) ->
    root.extend klass.prototype, mixin


# Dispatch any DOM event on element.
root.fire = (element, eventName) ->
    event = document.createEvent "HTMLEvents"
    event.initEvent eventName, true, true
    element.dispatchEvent event


# Message builder for content scripts.
#
# Example:
#
# root = exports ? this
# fub = require?('./funcbag') || root
# chrome.extension.sendMessage fub.Message.Creat('statSubs', {'filtered': count})
#
# Btw, 'Creat' is not a typo.
class root.Message
    constructor: (@name) ->

    encode: (hash) ->
        'msg': @name
        'data': hash

    @Creat: (name, hash) ->
        (new Message(name)).encode hash

    @extStorageGet = (group, name) ->
        Message.Creat 'extStorage.get', {'group': group, 'name': name}

    @extStorageGetGroup = (group) ->
        Message.Creat 'extStorage.getGroup', {'group': group}

    @extStorageGetAll = (group) ->
        Message.Creat 'extStorage.getAll', {}


# All functions operate with a simple color object as getWhite().
class root.Colour
    @getInvertedValue: (element, css) ->
        rgb = (window.getComputedStyle element)
            .getPropertyCSSValue(css).getRGBColorValue()
        color = {}
        for idx in ['red', 'green', 'blue']
            color[idx] = 255 - rgb[idx].getFloatValue CSSPrimitiveValue.CSS_NUMBER
        color

    @getWhite: ->
        {
            red: 255
            green: 255
            blue: 255
        }

    @getBlack: ->
        {
            red: 0
            green: 0
            blue: 0
        }

    @getContrastValue: (element, css) ->
        c = Colour.getInvertedValue element, css
        yiq = ((c.red * 299) + (c.green * 587) + (c.blue * 114)) / 1000;
#        console.log "#{element.innerText} #{yiq}"
        if yiq >= 127 then Colour.getWhite() else Colour.getBlack()

    @toRGBA: (color) ->
        "rgba(#{color.red}, #{color.green}, #{color.blue}, 1)"

    @invertBody: (element) ->
        element.style.backgroundColor = Colour.toRGBA (Colour.getInvertedValue element, 'background-color')
        element.style.color = Colour.toRGBA (Colour.getInvertedValue element, 'color')

