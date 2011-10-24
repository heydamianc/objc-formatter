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
	if (line ~ /^[ \t]*-[ \t]*(.+)[ \t]*(.+);/) {
		# @start-fragment parse
		line = condenseWhitespace(line)
		line = formatDash(line)
		line = stripSpaceInParentheses(line)
		line = stripSpaceAroundColon(line)
		line = spaceStar(line)
		line = leftAlignArguments(line)
		print line
		# @end-fragment parse
	}
}

# @start-fragment functions

function formatDash(line) {
	sub(/[ \t]*-[ \t]*\(/, "- (", line)
	return line
}

function stripSpaceInParentheses(line) {
	gsub(/\([ \t]*/, "(", line)
	gsub(/[ \t]*\)/, ")", line)
	return line
}

function stripSpaceAroundColon(line) {
	gsub(/[ \t]*\:[ \t]*/, ":", line)
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