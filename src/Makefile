CS := coffee

out := ../lib
coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(out)/%.js,$(coffee))

.PHONY: compile clean

all: compile

$(out)/%.js: %.coffee
	@mkdir -p `dirname $@`
	$(CS) -cp $< > $@

compile: $(js)

clean:
	rm -rf $(js)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
