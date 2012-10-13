root = exports ? this
crypt = require?('../vendor/md5') || root

class MyColors
    constructor: (@element) ->

    _getInvertedValue: (css) ->
        rgb = (window.getComputedStyle @element)
            .getPropertyCSSValue(css).getRGBColorValue()
        color = {}
        for idx in ['red', 'green', 'blue']
            color[idx] = 255 - rgb[idx].getFloatValue CSSPrimitiveValue.CSS_NUMBER
        color

    get: ->
        {
            b: @_getInvertedValue 'background-color'
            f: @_getInvertedValue 'color'
        }

    toRGBA: (color) ->
        "rgba(#{color.red}, #{color.green}, #{color.blue}, 1)"

    invert: ->
        cp = @get()
        @element.style.backgroundColor = @toRGBA cp.b
        @element.style.color = @toRGBA cp.f


class TextAreaState
    # src is a dom textarea object
    constructor: (@src) ->
        @state = null
        @src.addEventListener 'mouseover', =>
            @setState()
        , false

    setState: ->
        @state = crypt.md5 @src.value

    isModified: ->
        console.log "#{@state} == #{crypt.md5 @src.value}"
        !(@state == crypt.md5 @src.value)

class Options
    @DOWNLOAD_FILENAME = 'hnbl_settings.json'

    constructor: ->
        @btnSave = document.querySelector "[id='save']"
        @btnDefaults = document.querySelector "[id='defaults']"
        @btnDownload = document.querySelector "[id='download']"
        @btnUpload = document.querySelector "[id='upload']"

        @taHostname = document.querySelector '#hostname form textarea'
        @taUsername = document.querySelector '#username form textarea'
        @taLinktitleBl = document.querySelector '#linktitle-bl textarea'
        @taLinktitleWl = document.querySelector '#linktitle-wl textarea'

        @filters = [@taHostname, @taUsername, @taLinktitleBl, @taLinktitleWl]
        @gui = [
            @btnDefaults
            @btnSave
            @btnDownload
            @btnUpload
        ].concat @filters

        idx.mystate = new TextAreaState(idx) for idx in @filters

    # 'toggleGui true' forces to disable gui elements
    toggleGui: (to = null) ->
        state = to || true
        state = false if @btnDefaults.disabled && !to

        idx.disabled = state for idx in @gui

    # Load saved settings for element.
    # Use default values for unmodified settings.
    loadOpt: (element) ->
        val = ExtStorage.Get 'Filters', element.name
        element.value = (val || Conf.defaults['Filters'][element.name]).join "\n"

    loadSettings: ->
        @say @btnSave, 'Loading settings...', =>
            @loadOpt idx for idx in @filters

    guiBind: ->
        # default button
        @btnDefaults.addEventListener 'click', =>
            for idx in @filters
                idx.value = Conf.defaults['Filters'][idx.name].join "\n"
            @btnSave.disabled = false
        , false

        # save button
        @btnSave.addEventListener 'click', =>
            @saveSettings()
            @btnSave.disabled = true
        , false

        # all lists
        for idx in @filters
            idx.addEventListener 'change', =>
                @btnSave.disabled = false
            , false
            idx.addEventListener 'mouseout', (e) =>
                @btnSave.disabled = false if e.target.mystate.isModified()
            , false

        # download button
        @btnDownload.addEventListener 'click', =>
            @settingsDownload()
        , false

        @btnUpload.addEventListener 'click', =>
            c = new MyColors document.body
            c.invert()
        , false

    settingsDownload: ->
        @say @btnDownload, 'Pushing...', =>
            blob = new Blob [@getCurrentSettions()], {type: 'text/plain'}
            url = webkitURL.createObjectURL blob

            a = document.createElement 'a'
            a.download = Options.DOWNLOAD_FILENAME
            a.href = url
            a.click()

            webkitURL.revokeObjectURL url

    getCurrentSettions: ->
        o = {}
        o[idx.name] = parseRawData idx.value for idx in @filters
        JSON.stringify o

    saveSettings: ->
        @say @btnSave, 'Saving...', =>
            for idx in @filters
                ExtStorage.Set 'Filters', idx.name, (parseRawData idx.value)

    say: (element, msg, callback) ->
        orig = element.innerText
        element.innerText = msg

        @toggleGui true
        try
            callback()
        catch e
            alert "Error: #{e.message}"
            throw e
        finally
            element.innerText = orig
            @toggleGui()


# main
window.onload = ->
    opt = new Options()
    opt.loadSettings()
    opt.guiBind()
