.PHONY: build run clean watch watchrun

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  JAI := jai-macos
else ifeq ($(UNAME_S),Linux)
  JAI := jai-linux
else
  $(error Unsupported OS: $(UNAME_S))
endif

jcat: jcat.jai
	$(JAI) jcat.jai

build: jcat

build-release: jcat.jai
	$(JAI) -release jcat.jai

run: jcat
	./jcat

clean:
	rm -rf jcat .build jcat.dSYM

watchrun:
	find . -name '*.jai' ! -path './.build/*' | entr -r $(MAKE) run

watch:
	find . -name '*.jai' ! -path './.build/*' | entr -r $(MAKE) build