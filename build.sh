#! /usr/bin/env bash
set -e

if [ -f ./objc-formatter.awk ]
then
    rm ./objc-formatter.awk
fi

src/template.awk -v outputDir=./build src/objc-formatter.awk.template
