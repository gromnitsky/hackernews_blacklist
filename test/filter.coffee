assert = require 'assert'

filter = require '../lib/filter'

suite 'Filter', ->
    setup ->
        @fe = new filter.Filter('exact')
        @fr = new filter.Filter('regexp')

    test 'init', ->
        assert new filter.Filter('exact')

        assert.throws ->
            new filter.Filter
        assert.throws ->
            new filter.Filter 'um'

    test 'parse raw data', ->
        data = '  foo\n bar\n\n\n'
        assert.equal 'foo|bar', (@fe.parseRawData data).join '|'
        assert.equal '', (@fe.parseRawData '').join '|'
        assert.equal '', (@fe.parseRawData '  ').join '|'
        assert.equal '', (@fe.parseRawData '  \n ').join '|'

    test 'white set/get', ->
        data = '  foo\n bar\n\n\n'
        @fe.whiteSet data
        assert.equal 'foo\nbar', @fe.whiteGet()

        @fe.whiteSet ''
        assert.equal 0, @fe.whitelist.length
        assert.equal '', @fe.whiteGet()
