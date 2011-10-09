#! /usr/bin/env bash
set -e

rm objc-formatter.awk &> /dev/null
src/template.awk src/objc-formatter.awk.template
