# Objective-C Formatter

A code formatter for the Objective-C programming language

## Getting started

If you would like to generate your own `objc-formatter.awk` script, issue the following commands:

    git clone git://github.com/damiancarrillo/objc-formatter.git
    git submodule update --init
    make
    
At this point, `objc-formatter.awk` is available in the `build` directory.  You can use it by issuing the following command:

    ./objc-formatter.awk -v configFile=.../path/to/config/file .../path/to/source/file.m

## License

All content is released under the 
[BSD license](https://github.com/damiancarrillo/Objective-C-Formatter/blob/master/LICENSE.markdown). 
See [this page](http://www.linfo.org/bsdlicense.html) for a plain-text description of what this means.
