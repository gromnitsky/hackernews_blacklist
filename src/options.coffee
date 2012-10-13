root = exports ? this
mixin = require?('mixins') || root
filter = require?('filter') || root
storage = require?('extstorage') || root
defaults = require?('defaults') || root

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
#        console.log "#{@state} == #{crypt.md5 @src.value}"
        !(@state == crypt.md5 @src.value)

class Options
    @EXPORT_FILENAME = 'hnbl_settings.json'

    constructor: ->
        @btnSave = document.querySelector "[id='save']"
        @btnDefaults = document.querySelector "[id='defaults']"
        @btnExport = document.querySelector "[id='export']"
        @btnImport = document.querySelector "[id='import']"

        @taHostname = document.querySelector '#hostname form textarea'
        @taUsername = document.querySelector '#username form textarea'
        @taLinktitleBl = document.querySelector '#linktitle-bl textarea'
        @taLinktitleWl = document.querySelector '#linktitle-wl textarea'

        @filters = [@taHostname, @taUsername, @taLinktitleBl, @taLinktitleWl]
        @gui = [
            @btnDefaults
            @btnSave
            @btnExport
            @btnImport
        ].concat @filters

        idx.mystate = new TextAreaState(idx) for idx in @filters

        @bodyColors = new MyColors document.body

    # 'toggleGui true' forces to disable gui elements
    toggleGui: (to = null) ->
        state = to || true
        state = false if @btnDefaults.disabled && !to

        idx.disabled = state for idx in @gui

    # Load saved settings for element.
    # Use default values for unmodified settings.
    settingsLoadOpt: (element) ->
        val = storage.ExtStorage.Get 'Filters', element.name
        element.value = (val || defaults.Conf.defaults['Filters'][element.name]).join "\n"

    settingsLoad: ->
        @say @btnSave, 'Loading settings...', =>
            @settingsLoadOpt idx for idx in @filters
        @btnSave.disabled = true

    guiBind: ->
        # default button
        @btnDefaults.addEventListener 'click', =>
            for idx in @filters
                idx.value = defaults.Conf.defaults['Filters'][idx.name].join "\n"
            @btnSave.disabled = false
        , false

        # save button
        @btnSave.addEventListener 'click', =>
            @settingsSave()
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

        # export button
        @btnExport.addEventListener 'click', =>
            @settingsExport()
        , false

        # annoying import button
        @btnImport.addEventListener 'click', =>
            if @btnImport.innerText.match /^Drag/
                @btnImport.style.display = 'none'
            else
                @btnImport.innerText = 'Drag a .json file into this window'
        , false

        # DnD
        document.body.addEventListener 'dragenter', (event) =>
            event.stopPropagation()
            event.preventDefault()
            @bodyColors.invert()
        , false

        document.body.addEventListener 'dragleave', (event) =>
            event.stopPropagation()
            event.preventDefault()
            @bodyColors.invert()
        , false

        document.body.addEventListener 'drop', (event) =>
            event.stopPropagation()
            event.preventDefault()
            @bodyColors.invert()

            dt = event.dataTransfer
            if dt?.files.length != 1
                alert 'You need exactly 1 .json file. Try again.'
                return

            @settingsImport dt.files[0]
        , false

    settingsImport: (file) ->
        return unless file

        exit_now = false
        reader = new FileReader()
        reader.onerror = ->
            alert "Error reading '#{file.name}'"
            exit_now = true

        reader.onload = (data) =>
            return if exit_now

            r = null
            try
                r = JSON.parse data.target.result
            catch e
                alert "Error parsing '#{file.name}': #{e.message}"
                return

#            console.log r
            @say @btnImport, 'Loading settings...', =>
                idx.value = (r[idx.name]?.join "\n" || "") for idx in @filters

        reader.readAsText file

    settingsExport: ->
        @say @btnExport, 'Pushing...', =>
            blob = new Blob [@settingsGetCurrentAsString()], {type: 'text/plain'}
            url = webkitURL.createObjectURL blob

            a = document.createElement 'a'
            a.download = Options.EXPORT_FILENAME
            a.href = url
            a.click()

            webkitURL.revokeObjectURL url

    settingsGetCurrentAsString: ->
        o = {}
        o[idx.name] = filter.parseRawData idx.value for idx in @filters
        JSON.stringify o

    settingsSave: ->
        @say @btnSave, 'Saving...', =>
            for idx in @filters
                storage.ExtStorage.Set 'Filters', idx.name, (filter.parseRawData idx.value)

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
    opt.settingsLoad()
    opt.guiBind()
