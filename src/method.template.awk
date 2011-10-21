#! /usr/bin/env awk -f

BEGIN {
	# @start-fragment default-config
	
	# @end-fragment default-config

	# @include-fragment util.awk config

	while (getline line) {
		parseLine(line)
	}
}

function parseLine(line) {
	if (line ~ /^[ \t]*-[ \t]*(.+)[ \t]*(.+)/) {
		line = condenseWhitespace(line)
		line = formatDash(line)
		line = spaceStar(line)
		line = leftAlignArguments(line)
		print line
	}
}

# @start-fragment functions

function formatDash(line) {
	sub(/[ \t]*-[ \t]*\(/, "- (", line)
	return line
}

function spaceStar(line) {
	gsub(/[ \t]*\*\)/, " *)", line)
	return line
}

function leftAlignArguments(line) {
	gsub(/\)[ \t]*/, ")", line)
	return line
}

# @end-fragment functions

# @include-fragment util.awk functions