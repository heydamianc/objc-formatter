#! /usr/bin/env awk -f

BEGIN {
    split(ARGV[1], components, "\/")
    
    scriptName = components[length(components)]
    
    if (!index(scriptName, ".template")) {
        exitWithErrorMessage("Invalid template file - expected filename with .template suffix")
    }
    
    # strip .template suffix
    sub(/\.template/, "", scriptName)
    
    tempScriptPath = "/tmp/" scriptName
    scriptPath = "./" scriptName
    
    includeDir = ""
    
    for (i = 1; i < length(components); i++) {
        includeDir = includeDir components[i] "/"
    }
}
{
    if ($0 ~ /\#include-fragment/) {
        if (NF != 3) {
            errorMessage = "Unable to parse @include statement on line " \
                NR ".  Expected \"@include file fragment\", got \"" $0 "\"."
                
            exitWithErrorMessage(errorMessage)
        }
        
        line = $0

        location = index(line, "#")
        whitespace = ""

        for (i = 0; i < location - 1; i++) {
            whitespace = whitespace " "
        }
        
        fragmentFile = includeDir $2
        fragmentLabel = $3
        
        includeFragment(whitespace, fragmentFile, fragmentLabel)
    }
    else {
        print > tempScriptPath
    }
}
END {
    while ((getline line < tempScriptPath) > 0) {
        print line >> scriptPath
    }
}

function includeFragment(linePrefix, fragmentFile, fragmentLabel) {
    while ((getline line < fragmentFile) > 0) {
        if (line ~ "#start-fragment " fragmentLabel) {
            while ((getline line < fragmentFile) > 0) {
                if (line ~ "#end-fragment " fragmentLabel) {
                    return
                }
                print line > tempScriptPath
            }
        }
    }
    
    exitWithErrorMessage("Unable to find fragment with label \"" fragmentLabel "\" in " fragmentFile)
}

function exitWithErrorMessage(errorMessage) {        
    system("echo 'Error: " errorMessage "' 1>&2")
    exit 1
}