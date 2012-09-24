assert = require 'assert'

filter = require '../lib/filter'

suite 'Filter', ->
    setup ->
        @fe = new filter.Filter('exact')
        @fr = new filter.Filter('regexp', false)

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

    test 'match exact', ->
        @fe.whiteSet 'foo\nbar\nlist'
        @fe.blackSet 'list\narray'

        assert.equal false, @fe.match 'list'
        assert.equal true, @fe.match 'array'
        @fe.whiteSet ''
        assert.equal true, @fe.match 'list'

    test 'match regexp', ->
        @fr.whiteSet 'foo\nbar\nlist' # must be ignored, see setup
        @fr.blackSet 'list\narray'

        assert.equal true, @fr.match 'a list in the forrest'
        assert.equal true, @fr.match 'array!'
        @fe.whiteSet ''
        assert.equal true, @fr.match 'array!'
        @fr.blackSet ''
        assert.equal false, @fr.match 'list'
