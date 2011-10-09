#! /usr/bin/env awk -f

{
    line = $0
    
    if (line ~ /@property/) {
        
    }
}

# @start-fragment functions

function trim(s) {
  sub(/^[ \t]*/, "", s)
  sub(/[ \t]*$/, "", s)
  return s
}

function condenseWhitespace(s) {
  gsub(/[ \t]+/, " ", s)
  return s
}

function max(m, n) {
  return m > n ? m : n
}

# @end-fragment functions