InjectorInterface =
    isUrlValid: (url) ->
        (return true if url.match(idx)) for idx in @permissions
        false

    onUpdatedCallback: (tabId, changeInfo, tab) ->
        return unless changeInfo.status != 'complete'

        if @isUrlValid(tab.url)
            chrome.pageAction.show tabId
            
            print_info = (t) -> console.log "bg: script injected #{t}"

            # inject scripts
            for idx in @scripts
                chrome.tabs.executeScript tabId, {file: idx}, print_info(idx)
        
class InjectorSubs
    constructor: ->
        @scripts = [
            'lib/funcbag.js'
            'lib/filter.js'
            'lib/content_subs.js'
            ]
    
        @permissions = ["^https?://news.ycombinator.com/(x\\?fnid=.+|newest|ask|jobs|news)?$",
            "^file://.+/hackernews_blacklist/test/data/news\\.ycombinator\\.com/index\\.html$"]

include InjectorSubs, InjectorInterface

class InjectorComments
    constructor: ->
        @scripts = [
            'lib/funcbag.js'
            'lib/filter.js'
            'lib/content_comments.js'
            ]
    
        @permissions = ["^https?://news.ycombinator.com/item\\?id=\\d+$",
            "^file://.+/hackernews_blacklist/test/data/news\\.ycombinator\\.com/item"]

include InjectorComments, InjectorInterface

analyze_uri = (tabId, changeInfo, tab) ->
    subs = new InjectorSubs()
    subs.onUpdatedCallback tabId, changeInfo, tab
    comments = new InjectorComments()
    comments.onUpdatedCallback tabId, changeInfo, tab

# Return file contents. Plain sync version.
read_file = (file) ->
    r = new XMLHttpRequest()
    r.open "GET", file, false
    r.send null
    r.responseText

# listen for any changes to the url of any tab
chrome.tabs.onUpdated.addListener analyze_uri


chrome.extension.onMessage.addListener (req, sender, sendRes) ->
    return unless req.msg

    switch req.msg
        when 'extStorage.get'
            sendRes ExtStorage.Get req.data.group, req.data.name
        when 'extStorage.getGroup'
            sendRes ExtStorage.GetGroup req.data.group
        when 'extStorage.getAll'
            filters = ExtStorage.GetGroup 'Filters'
            favorites = ExtStorage.GetGroup 'Favorites'
            sendRes {Filters: filters, Favorites: favorites}
        when 'statSubs'
            chrome.pageAction.setTitle
                tabId: sender.tab.id
                title: "#{req.data.filtered} submissions filtered"
        when 'statComments'
            chrome.pageAction.setTitle
                tabId: sender.tab.id
                title: "#{req.data.total-req.data.collapsed} new, #{req.data.collapsed} read, #{req.data.total} total"
        when 'commentsGetContentsHTML'
            # send raw html
            file = 'lib/content_comments_contents.html'
            html = read_file file
            sendRes {html: html}
            console.log "bg: html send: #{file}"
        else
            new Error("unknown message name: #{req.msg}")

Conf.loadSettings()
console.log 'bg: loaded'
