root = exports ? this

# Default settings for background.js, where they go into localStorage &
# for options.html, where they serve 'Defaults' button.

class root.Conf
    @defaults =
        'Filters':
            'hostname' : [
                'huffingtonpost.com'
                'www.apple.com'
                'www.marco.org'
                'www.codinghorror.com'
                'www.slate.com'
                'joel.is'
                'daringfireball.net'
                'www.kalzumeus.com'
            ]
            'username' : []
            'linktitle-bl' : [
                '\\bApple\\b'
                '\\bIOS(\\d+)?\\b'
                'Iphone'
                '\\bIp[ao]d'
                '\\bMac(book)?\\b'
                '\\b(Mac\\s+)?OS(\\s+)?X\\b'
                '\\bRetina\\b'
                '\\bIcloud'
                '\\bItunes'
                'Python'
                'Django'
                'Pycon'
                '\\bPatent'
                'Typography'
                'Legislation'
                'Goverment'
                'Court\\b'
                'Instagram'
                '\\bVim\\b'
                'Pinterest'
                'A/B\\sTest'
                'Steve?\\s+Jobs'
                'Pirate'
                'Torrent'
                'App\\.net'
                '\\bAsp\\.net'
                'Nokia'
                '\\bFlash'
                'meetup'
            ]
            'linktitle-wl' : ['ruby', 'rails']

    # Load defauls into localStorage unless localStorage are not filled
    # with user settings.
    @loadSettings: ->
        for key, val of Conf.defaults['Filters']
            ls = ExtStorage.Get 'Filters', key
            ExtStorage.Set 'Filters', key, val unless ls
        