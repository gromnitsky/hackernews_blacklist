# https://github.com/jashkenas/coffee-script/issues/218#issuecomment-146909

root = exports ? this

root.extend = (obj, mixin) ->
    obj[name] = method for name, method of mixin

root.include = (klass, mixin) ->
    root.extend klass.prototype, mixin
