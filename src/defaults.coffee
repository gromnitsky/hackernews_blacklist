root = exports ? this

# Default settings for background.js, where they go into localStorage &
# for options.html, where they serve 'Defaults' button.

class root.Conf
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

    # Load defauls into localStorage unless localStorage are not filled
    # with user settings.
    @loadSettings: ->
        for key, val of Conf.defaults['Filters']
            ls = ExtStorage.Get 'Filters', key
            ExtStorage.Set 'Filters', key, val unless ls
        