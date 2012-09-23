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
            # execute script
            console.log 'executing script!'

# listen for any changes to the url of any tab
chrome.tabs.onUpdated.addListener Manager.onUpdatedCallback
console.log 'background page: loaded'
