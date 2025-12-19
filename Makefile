.PHONY: build run clean watch

jbird: jbird.jai
	jai-macos jbird.jai

build: jbird

run: jbird
	./jbird

clean:
	rm -rf jbird .build jbird.dSYM

watchrun:
	find . -name '*.jai' ! -path './.build/*' | entr -r make run

watch:
	find . -name '*.jai' ! -path './.build/*' | entr -r make build