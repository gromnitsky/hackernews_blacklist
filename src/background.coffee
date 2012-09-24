# perfect name, xoxo
class Manager
    @permissions = ["^https?://news.ycombinator.com/(x\\?fnid=.+|newest|ask|jobs)?$",
        "^file://.+/hackernews_blacklist/test/data/news\\.ycombinator\\.com/index\\.html$"]

    @isUrlValid: (url) ->
        (return true if url.match(idx)) for idx in @permissions
        false

    @onUpdatedCallback: (tabId, changeInfo, tab) ->
        return unless changeInfo.status != 'complete'

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
        when 'extStorage.get' then sendRes ExtStorage.Get req.data.group, req.data.name
        when 'extStorage.getGroup' then sendRes ExtStorage.GetGroup req.data.group
        else new Error("unknown message name: #{req.msg}")

ExtStorage.Set 'test', 'foo', "foo's value!"
ExtStorage.Set 'test', 'bar', "bar's value!"
console.log 'bg: loaded'
