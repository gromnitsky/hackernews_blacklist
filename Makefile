CS := coffee
MOCHA := node_modules/.bin/mocha
JSONTOOL := json
M4 = gm4

INFO := package.json
NAME := $(shell $(JSONTOOL) name < $(INFO))
VER := $(shell $(JSONTOOL) version < $(INFO))
ZIP := $(NAME)-$(VER).zip

OPTS :=
out := lib

all: test

test-data-get:
	(cd test/data && rm -rf * && \
		wget -E -H -k -K -p http://news.ycombinator.com; \
	find . -name '*.orig' | xargs rm -f)

node_modules: package.json
	npm install
	touch $@

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd $(OPTS)

manifest_clean:
	rm -f manifest.json

manifest.json: manifest.m4
	$(M4) $< > $@

compile: node_modules manifest.json
	$(MAKE) -C src

clean: manifest_clean
	$(MAKE) -C src clean

clobber: clean
	rm -rf node_modules

zip_clean:

zip: $(INFO) zip_clean compile
	zip $(ZIP) `$(JSONTOOL) files < $< | $(JSONTOOL) -a`

.PHONY: test-data-get test compile manifest_clean clean clobber zip zip_clean

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
