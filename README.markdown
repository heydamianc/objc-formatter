# Objective-C Formatter

A code formatter for the Objective-C programming language

## Getting started

If you would like to generate your own `objc-formatter.awk` script, issue the following commands:

    git clone git://github.com/damiancarrillo/objc-formatter.git
	cd objc-formatter
    git submodule update --init
    make
    
At this point, `objc-formatter.awk` is available in the `build` directory.  You can use it by issuing the following command:

    ./objc-formatter.awk .../path/to/source/file.m

## Xcode Integration

You can integrate the objc-formatter.awk script into Xcode by placing it in the root directory
of your project.  Once you have done that, add a new Shell Script Build Phase that runs prior
to compilation.  It should have the following script:

    for sourceFile in YourProject/Classes/*.[h,m]
    do
        printf "Formatting ${sourceFile}..." && ./objc-formatter.awk ${sourceFile} > \
            ${sourceFile}.fmt && mv ${sourceFile}.fmt ${sourceFile} && echo "done"
    done

The path to your classes can be relative to the project's root directory.

## License

All content is released under the 
[BSD license](https://github.com/damiancarrillo/Objective-C-Formatter/blob/master/LICENSE.markdown). 
See [this page](http://www.linfo.org/bsdlicense.html) for a plain-text description of what this means.
