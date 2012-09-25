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

    loadSettings: ->
        @btnSave.disabled = true

    guiBind: ->
        # default button
        @btnDefaults.addEventListener 'click', =>
            for idx in [@taDomain, @taUsername, @taLinktitleBl, @taLinktitleWl]
                idx.value = Options.defaults['Filters'][idx.name].join "\n"
            @btnSave.disabled = false
        , false

        # save button
        @btnSave.addEventListener 'click', =>
            @say "wait please", () ->
                throw new Error('woot')
                true
        , false

     say: (msg, callback) ->
         orig = @btnSave.innerText
         @btnSave.innerText = msg
         @btnSave.disabled = true

         try
             callback()
         catch e
             alert "Error: #{e.message}"
             throw e
         finally
             @btnSave.innerText = orig
             @btnSave.disabled = false


# main
window.onload = ->
    opt = new Options()
    opt.loadSettings()
    opt.guiBind()

