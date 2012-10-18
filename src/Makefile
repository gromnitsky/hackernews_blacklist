BROWSERIFY := ../node_modules/.bin/browserify
JADE := ../node_modules/.bin/jade

out := ../lib

coffee := background.coffee content_subs.coffee content_comments.coffee options.coffee
js := $(patsubst %.coffee,$(out)/%.js,$(coffee))

jade := $(wildcard *.jade)
html := $(patsubst %.jade,$(out)/%.html,$(jade))

.PHONY: compile clean

all: compile

defaults.coffee: extstorage.coffee
filter.coffee: funcbag.coffee
background.coffee: funcbag.coffee defaults.coffee

content_subs.coffee: filter.coffee
content_comments.coffee: filter.coffee

options.coffee: filter.coffee defaults.coffee

$(out)/%.js: %.coffee
	@mkdir -p `dirname $@`
	$(BROWSERIFY) $< -o $@

$(out)/%.html: %.jade
	@mkdir -p `dirname $@`
	$(JADE) -o `coffee -e "d = require('./defaults'); o = {}; o.locals = d.Conf.defaults.Favorites; console.log(JSON.stringify(o))"` -P < $< > $@

compile: $(js) $(html)

clean:
	rm -rf $(js) $(html)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
