# Hacker News Blacklist

A Chrome extension for http://news.ycombinator.com. It collapses
uninteresting links via title, host name or user name filters.

Build requirements:

* CoffeeScript installed via npm in global (`-g`) mode.
* jsontool in global mode.
* GNU m4 (on Fedora, make a symlink `ln -s /usr/m4 ~/bin/gm4`).
* xxd utility.
* GNU make.

To compile, run

    $ make compile

To make a .crx file, you'll need a private RSA key named `private.pem`
in the same directory where Makefile is. For testing purposes, generate
it with openssl:

    $ openssl genrsa -out private.pem 1024

and run:

    $ make crx

If everything was fine, `hackernews_blacklist-x.y.z.crx` file will appear.
