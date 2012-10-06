InjectorInterface =
    isUrlValid: (url) ->
        (return true if url.match(idx)) for idx in @permissions
        false

    onUpdatedCallback: (tabId, changeInfo, tab) ->
        return unless changeInfo.status != 'complete'

        if @isUrlValid(tab.url)
            chrome.pageAction.show tabId
            
            # inject scripts
            for idx in @scripts
                console.log "bg: injecting #{idx}"
                chrome.tabs.executeScript tabId, {file: idx}, ->
                    console.log "bg: script injected"
        
class InjectorSubs
    constructor: ->
        @scripts = [
            'lib/mixins.js'
            'lib/filter.js'
            'lib/extstorage.js'
            'lib/content_subs.js'
            ]
    
        @permissions = ["^https?://news.ycombinator.com/(x\\?fnid=.+|newest|ask|jobs|news)?$",
            "^file://.+/hackernews_blacklist/test/data/news\\.ycombinator\\.com/index\\.html$"]

include InjectorSubs, InjectorInterface

class InjectorComments
    constructor: ->
        @scripts = [
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

# listen for any changes to the url of any tab
chrome.tabs.onUpdated.addListener analyze_uri


chrome.extension.onMessage.addListener (req, sender, sendRes) ->
    return unless req.msg

    switch req.msg
        when 'extStorage.get'
            sendRes ExtStorage.Get req.data.group, req.data.name
        when 'extStorage.getGroup'
            sendRes ExtStorage.GetGroup req.data.group
        when 'stat'
            chrome.pageAction.setTitle
                'tabId': sender.tab.id
                'title': "#{req.data.filtered} submissions filtered"
        else
            new Error("unknown message name: #{req.msg}")

Conf.loadSettings()
console.log 'bg: loaded'
