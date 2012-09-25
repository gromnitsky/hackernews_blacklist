assert = require 'assert'

filter = require '../lib/filter'

suite 'Filter', ->
    setup ->
        @fe = new filter.FilterExact()
        @fr = new filter.FilterRegexp false

    test 'parse raw data', ->
        data = '  foo\n bar\n\n\n'
        assert.equal 'foo|bar', (filter.parseRawData data).join '|'
        assert.equal '', (filter.parseRawData '').join '|'
        assert.equal '', (filter.parseRawData '  ').join '|'
        assert.equal '', (filter.parseRawData '  \n ').join '|'

    test 'white set/get', ->
        data = '  foo\n bar\n\n\n'
        @fe.whiteSet data
        assert.equal 'foo\nbar', @fe.whiteGet()

        @fe.whiteSet ''
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
