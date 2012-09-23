CS := coffee
MOCHA := node_modules/.bin/mocha

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
	$(MOCHA) --compilers coffee:coffee-script -u tdd

compile: node_modules
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean

clobber: clean
	rm -rf node_modules


.PHONY: test-data-get test compile clean clobber

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
