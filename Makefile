all: objc-formatter.awk

objc-formatter.awk: synthesize.awk
	./template.awk -v output=build/objc-formatter.awk -v include=build src/objc-formatter.awk.template
	
synthesize.awk: util.awk
	./template.awk -v output=build/synthesize.awk -v include=build src/synthesize.awk.template

util.awk: create-build-dir
	./template.awk -v output=build/util.awk src/util.awk.template

create-build-dir:
	mkdir build > /dev/null 2>&1

clean:
	rm -rf build
