#! /usr/bin/env awk -f
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright © 2011, Damian Carrillo
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the names of its contributors 
#   may be used to endorse or promote products derived from this software 
#   without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY 
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# template.awk
# 
# 2011-10-08
# 
# Usage:
#   $ ./template.awk -v output=.../path/to/output/file \
#                    -v include=.../path/to/include/dir \
#                    .../path/to/template/file
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN {
    if (output) {
        outputFilePath = output
    }
    else {
        outputFilePath = "./" ARGV[1] ".out"
    }
    
    if (include) {
        includeDir = include "/"
    }
    else {
        includeDir = ""
        
        for (i = 1; i < length(components); i++) {
            includeDir = includeDir components[i] "/"
        }
    }
    
    split(ARGV[1], components, "\/")
    tempFileName = components[length(components)]
    tempOutputFilePath = "/tmp/" tempFileName
    
    if (v == 1) {
        print "outputFilePath:     " outputFilePath
        print "includeDir:         " includeDir
        print "tempOutputFilePath: " tempOutputFilePath
    }
}
{
    if ($0 ~ /\@include-fragment/) {
        line = $0
    
        sub(/.*@include-fragment/, "", line)
        split(line, arguments)
        
        if (length(arguments) < 2) {
            errorMessage = "Unable to parse @include statement on line " \
                NR ".  Expected \"#include-fragment file fragment\", " \
                "got \"" line "\"."
                
            exitWithErrorMessage(errorMessage)
        }

        location = index(line, "#")
        whitespace = ""

        for (i = 0; i < location - 1; i++) {
            whitespace = whitespace " "
        }
        
        fragmentFile = includeDir arguments[1]
        fragmentLabel = arguments[2]
        
        if (fileExists(fragmentFile)) {
            includeFragment(whitespace, fragmentFile, fragmentLabel)
        } else {
            exitWithErrorMessage("Unable to find " fragmentFile " on line " NR)
        }
    }
    else {
        print > tempOutputFilePath
    }
}
END {
    while ((getline line < tempOutputFilePath) > 0) {
        print line > outputFilePath
    }
    close(tempOutputFilePath)
}

function includeFragment(linePrefix, fragmentFile, fragmentLabel) {
    while ((getline line < fragmentFile) > 0) {
        if (line ~ "@start-fragment " fragmentLabel) {
            while ((getline line < fragmentFile) > 0) {
                if (line ~ "@end-fragment " fragmentLabel) {
                    close(fragmentFile)
                    return
                }
                print line > tempOutputFilePath
            }
        }
    }
    
    exitWithErrorMessage("Unable to find fragment with label \"" \
        fragmentLabel "\" in " fragmentFile)
}

function exitWithErrorMessage(errorMessage) {        
    system("echo 'Error: " errorMessage "' 1>&2")
    exit 1
}

# 
# The shell's version of truth differs from awk's, so make the test conveniently switch them
#
function fileExists(file) {
    exists = system("test -f " file)
    
    if (exists == 0) {
        exists = 1
    }
    else {
        exists = 0
    }
    
    return exists
}