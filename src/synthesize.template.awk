#! /usr/bin/env awk -f

BEGIN {
	RS=";"
}
/@synthesize/ {
	print "[" $0 "]"
}
END {

}