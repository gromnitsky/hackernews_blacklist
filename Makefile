CS := coffee
MOCHA := node_modules/.bin/mocha
JSONTOOL := json
M4 = gm4

INFO := package.json
NAME := $(shell $(JSONTOOL) name < $(INFO))
VER := $(shell $(JSONTOOL) version < $(INFO))
ZIP := $(NAME)-$(VER).zip
CRX := $(NAME)-$(VER).crx
PRIVATE_KEY := private.pem

OPTS :=
out := lib

all: test

test-data-get:
	(cd test/data && rm -rf * && \
		wget -E -H -k -K -p \
			http://news.ycombinator.com \
			"https://news.ycombinator.com/item?id=4638286" \
			"https://news.ycombinator.com/item?id=4630057"; \
	find . -name '*.orig' | xargs rm -f)

node_modules: package.json
	npm install
	touch $@

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd $(OPTS)

manifest_clean:
	rm -f manifest.json

manifest.json: manifest.m4 package.json
	$(M4) $< > $@

compile: node_modules manifest.json
	$(MAKE) -C src

clean: manifest_clean zip_clean crx_clean
	$(MAKE) -C src clean

clobber: clean
	rm -rf node_modules

zip_clean:
	rm -f $(ZIP)

zip: $(INFO) zip_clean compile
	zip $(ZIP) `$(JSONTOOL) files < $< | $(JSONTOOL) -a`

id:
	@openssl rsa -pubout -outform DER < $(PRIVATE_KEY) 2>/dev/null \
		| openssl dgst -sha256 | \
		cut -f2 -d' ' | cut -c 1-32 | tr '0-9a-f' 'a-p'

crx_clean:
	rm -f $(CRX)

crx: crx_clean zip
	./zip2crx.sh $(ZIP) $(PRIVATE_KEY)

.PHONY: test-data-get test compile manifest_clean clean clobber \
	zip zip_clean crx crx_clean

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
