class Options
    @defaults =
        'Filters':
            'domain' : ['huffingtonpost.com']
            'username' : []
            'linktitle-bl' : [
                '\\bApple\\b'
                '\\bIOS\\b'
                'Iphone'
                '\\bIp[ao]d'
                '\\bMac\\b'
                '\\b(Mac\s+)?OS(\\s+)?X\\b'
                'Python'
                'Java\\b'
                ]
            'linktitle-wl' : ['ruby']

    constructor: ->
        @btnSave = document.querySelector "[id='save']"
        @btnDefaults = document.querySelector "[id='defaults']"
        @taDomain = document.querySelector '#domain form textarea'
        @taUsername = document.querySelector '#username form textarea'
        @taLinktitleBl = document.querySelector '#linktitle-bl textarea'
        @taLinktitleWl = document.querySelector '#linktitle-wl textarea'

        @filters = [@taDomain, @taUsername, @taLinktitleBl, @taLinktitleWl]
        @gui = [@btnDefaults, @btnSave].concat @filters

    toggleGui: (to = null) ->
        state = to || true
        state = false if @btnDefaults.disabled && !to

        idx.disabled = state for idx in @gui

    # Load saved settings for element.
    # Use default values for unmodified settings.
    loadOpt: (element) ->
        val = ExtStorage.Get 'Filters', element.name
        console.log val
        element.value = (val || Options.defaults['Filters'][element.name]).join "\n"
        
    loadSettings: ->
        @say 'Loading settings...', =>
            @loadOpt idx for idx in @filters

        @btnSave.disabled = true

    guiBind: ->
        # default button
        @btnDefaults.addEventListener 'click', =>
            for idx in @filters
                idx.value = Options.defaults['Filters'][idx.name].join "\n"
            @btnSave.disabled = false
        , false

        # save button
        @btnSave.addEventListener 'click', =>
            @saveSettings()
        , false

        # all lists
        for idx in @filters
            idx.addEventListener 'change', =>
                @btnSave.disabled = false
            , false

    saveSettings: ->
        @say 'Saving...', =>
            for idx in @filters
                ExtStorage.Set 'Filters', idx.name, (Filter.parseRawData idx.value)

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

