# https://github.com/jashkenas/coffee-script/issues/218#issuecomment-146909
exports.extend = (obj, mixin) ->
    obj[name] = method for name, method of mixin

exports.include = (klass, mixin) ->
    exports.extend klass.prototype, mixin


# Dispatch any DOM event on element.
exports.fire = (element, eventName) ->
    event = document.createEvent "HTMLEvents"
    event.initEvent eventName, true, true
    element.dispatchEvent event


exports.val2key = (hash) ->
    r = {}
    r[val] = key for key, val of hash
    r

exports.isNum = (n) -> !isNaN(parseFloat n) && isFinite n

# Message builder for content scripts.
#
# Example:
#
# exports = exports ? this
# fub = require?('./funcbag') || exports
# chrome.extension.sendMessage fub.Message.Creat('statSubs', {'filtered': count})
#
# Btw, 'Creat' is not a typo.
class exports.Message
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
class exports.Colour

    @str2rgb: (str) ->
        m = str?.match /(\d{1,3}), *(\d{1,3}), *(\d{1,3})/
        return null unless m
        {
            red: parseInt m[1]
            green: parseInt m[2]
            blue: parseInt m[3]
        }

    @getInvertedValue: (element, css) ->
        rgb = Colour.str2rgb (window.getComputedStyle element).getPropertyValue(css)
        throw new Error "cannot parse `#{css}` value" unless rgb
        (rgb[key] = 255 - val) for key,val of rgb
        rgb

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

    @paintBox: (element, color) ->
        element.style.padding = '0px 3px 0px 3px'
        element.style.background = color

        rgb = Colour.getContrastValue element, 'background-color'
        element.style.color = Colour.toRGBA rgb
        element.style.border = "1px solid #{Colour.toRGBA rgb}"

    @paintBoxIn: (element, fgcolor) ->
        element.style.padding = '0px 3px 0px 3px'
        element.style.color = fgcolor
        element.style.border = "1px solid #{fgcolor}"
