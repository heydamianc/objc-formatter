#! /usr/bin/env awk -f

BEGIN {
	# @start-fragment config
	if (configFile) {
		readConfig(configFile)
	}

	if (verbose) {
		printConfig(config)
	}
	# @end-fragment config
}
{
	print
}

# @start-fragment functions

function readConfig(configFile) {
	while (getline line < configFile) {
		if (line ~ /^[a-zA-Z1-0_-]+[ \t]*=/) {
			sub(/[ \t]*=[ \t]*/, "=", line)
			split(line, lineElements, " ")
			split(lineElements[1], configElements, "=")
			config[configElements[1]] = configElements[2]
		}
	}
	close(configFile)
}

function printConfig(config) {
	print ".- Config -------------------------------------------------" \
		"--------------------."

	maxEntry = 0

	for (entry in config) {
		maxEntry = max(maxEntry, length(entry))
	}

	remaining = 73 - maxEntry

	format = "| %-" maxEntry "s = %-" remaining "s |\n"

	for (entry in config) {
		printf(format, entry, config[entry])
	}

	print "'---------------------------------------------------------" \
		"---------------------'"
}

function trim(s) {
	return trimLeadingWhitespace(trimTrailingWhitespace(s))
}

function trimLeadingWhitespace(s) {
	sub(/^[ \t]*/, "", s)
	return s
}

function trimTrailingWhitespace(s) {
	sub(/[ \t]*$/, "", s)
	return s
}

function condenseWhitespace(s) {
	gsub(/[ \t]+/, " ", s)
	return s
}

function detab(s, r) {
	gsub(/\t/, r, s)
	return s
}

function maxLengthOf(candidates) {
	maxLength = 0

	len = length(candidates)

	for (i = 1; i <= len; i++) {
		maxLength = max(maxLength, length(candidates[i]));
	}

	return maxLength
}

function max(m, n) {
	return m > n ? m : n
}

# @end-fragment functions