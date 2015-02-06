assert = require 'assert'

funcbag = require '../src/funcbag'

suite 'Colour', ->
    setup ->

    test 'str2rgb', ->
        assert.equal null, funcbag.Colour.str2rgb null
        assert.equal null, funcbag.Colour.str2rgb ""
        assert.deepEqual {red:1,green:2,blue:3}, funcbag.Colour.str2rgb "1, 2, 3"
        assert.deepEqual {red:255,green:255,blue:0}, funcbag.Colour.str2rgb 'rgb(255, 255, 0)'
