root = exports ? this
crypt = require?('../vendor/md5') || root

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
    constructor: ->
        @btnSave = document.querySelector "[id='save']"
        @btnDefaults = document.querySelector "[id='defaults']"
        @taHostname = document.querySelector '#hostname form textarea'
        @taUsername = document.querySelector '#username form textarea'
        @taLinktitleBl = document.querySelector '#linktitle-bl textarea'
        @taLinktitleWl = document.querySelector '#linktitle-wl textarea'

        @filters = [@taHostname, @taUsername, @taLinktitleBl, @taLinktitleWl]
        @gui = [@btnDefaults, @btnSave].concat @filters

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
        @say 'Loading settings...', =>
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

    saveSettings: ->
        @say 'Saving...', =>
            for idx in @filters
                ExtStorage.Set 'Filters', idx.name, (parseRawData idx.value)

    say: (msg, callback) ->
        orig = @btnSave.innerText
        @btnSave.innerText = msg

        @toggleGui true
        try
            callback()
        catch e
            alert "Error: #{e.message}"
            throw e
        finally
            @btnSave.innerText = orig
            @toggleGui()


# main
window.onload = ->
    opt = new Options()
    opt.loadSettings()
    opt.guiBind()

