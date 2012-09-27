# A perfect name, xoxo.
class Manager
    @tab = null
    
    @permissions = ["^https?://news.ycombinator.com/(x\\?fnid=.+|newest|ask|jobs)?$",
        "^file://.+/hackernews_blacklist/test/data/news\\.ycombinator\\.com/index\\.html$"]

    @isUrlValid: (url) ->
        (return true if url.match(idx)) for idx in @permissions
        false

    @onUpdatedCallback: (tabId, changeInfo, tab) ->
        return unless changeInfo.status != 'complete'
        Manager.tab = tabId # save this for later use outside of this callback

        if Manager.isUrlValid(tab.url)
            chrome.pageAction.show(tabId)
            # inject script
            chrome.tabs.executeScript tabId, {file: "lib/content.js"}, ->
                console.log 'bg: script injected'

# listen for any changes to the url of any tab
chrome.tabs.onUpdated.addListener Manager.onUpdatedCallback

chrome.extension.onMessage.addListener (req, sender, sendRes) ->
    return unless req.msg

    switch req.msg
        when 'extStorage.get'
            sendRes ExtStorage.Get req.data.group, req.data.name
        when 'extStorage.getGroup'
            sendRes ExtStorage.GetGroup req.data.group
        when 'stat'
            chrome.pageAction.setTitle
                'tabId': Manager.tab
                'title': "#{req.data.filtered} links filtered"
        else
            new Error("unknown message name: #{req.msg}")

Conf.loadSettings()
console.log 'bg: loaded'
