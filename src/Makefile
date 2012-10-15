CS := coffee
JADE := ../node_modules/.bin/jade

out := ../lib

coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(out)/%.js,$(coffee))

jade := $(wildcard *.jade)
html := $(patsubst %.jade,$(out)/%.html,$(jade))

.PHONY: compile clean

all: compile

$(out)/%.js: %.coffee
	@mkdir -p `dirname $@`
	$(CS) -cp $< > $@

$(out)/%.html: %.jade
	@mkdir -p `dirname $@`
	$(JADE) -o `node -e "d = require('../lib/defaults'); o = {}; o.locals = d.Conf.defaults.Favorites; console.log(JSON.stringify(o))"` -P < $< > $@

compile: $(js) $(html)

clean:
	rm -rf $(js) $(html)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
