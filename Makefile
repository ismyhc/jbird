.PHONY: build run clean watch watchrun

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  JAI := jai-macos
else ifeq ($(UNAME_S),Linux)
  JAI := jai-linux
else
  $(error Unsupported OS: $(UNAME_S))
endif

jbird: jbird.jai
	$(JAI) jbird.jai

build: jbird

run: jbird
	./jbird

clean:
	rm -rf jbird .build jbird.dSYM

watchrun:
	find . -name '*.jai' ! -path './.build/*' | entr -r $(MAKE) run

watch:
	find . -name '*.jai' ! -path './.build/*' | entr -r $(MAKE) build