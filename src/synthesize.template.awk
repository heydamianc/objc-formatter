#! /usr/bin/env awk -f

BEGIN {
	# @start-fragment default-config

	# Possible Values: 1 - 2
	#
	#   1: Push all synthesizers to the left as far as possible
	#      @synthesize tableView = _tableView;
	#      @synthesize fetchedResultsController = _fetchedResultsController;
	#
	#   2: Line up both the left hand and right hand side of the alias assignment
	#      @synthesize tableView                = _tableView;
	#      @synthesize fetchedResultsController = _fetchedResultsController;
	#
	config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] = 2
	# @end-fragment default-config

	# @include-fragment util.awk config

	while (getline line) {
		parseLine(line)
	}
}

function parseLine(line) {
	if (line ~ /@synthesize/) {
		# @start-fragment parse
		readSynthesizers(line, properties, aliases)
		# @end-fragment parse
	}
}

# @start-fragment functions

function readSynthesizers(line, properties, aliases) {
	while (line ~ /@synthesize/ && !index(line, ";")) {
		getline anotherLine
		line = line anotherLine
	}

	extractSynthesizers(line, properties, aliases)
	getline line

	if (line ~ /@synthesize/ || line ~ /^[ \t]*$/) {
		readSynthesizers(line, properties, aliases)
	} else {
		formatSynthesizers(properties, aliases)
		
		# clean up
		
		delete properties
		delete aliases
		
		# continue parsing the line that was just read
		
		parseLine(line)
	}
}

function extractSynthesizers(line, properties, aliases) {
	gsub("@synthesize", "", line)
	gsub(";", "", line)
	gsub(/[ \t]*/, "", line)

	split(line, directives, ",")
	len = length(directives)

	for (i = 1; i <= len; i++) {

		# The components of the directive are the LHS and RHS of the alias assignment, so for
		# @synthesize a = _a, component[1] would be 'a' and component[2] would be 'b'

		split(directives[i], components, "=")

		if (length(components[1]) > 0) { # avoid lines with only whitespace
			j = length(properties) + 1
			properties[j] = components[1]

			if (length(components) > 1) {
				aliases[j] = components[2]
			} else {
				aliases[j] = components[1]
			}
		}
	}
}

function formatSynthesizers(properties, aliases) {
	len = length(properties)

	maxLength = maxLengthOf(properties)

	for (i = 1; i <= len; i++) {
		format = ""

		if (config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] == 1) {
			format = "@synthesize %s = %s;\n"
		} else {
			format = "@synthesize %-" maxLength "s = %s;\n"
		}

		printf(format, properties[i], aliases[i])
	}

	print ""
}

# @end-fragment functions

# @include-fragment util.awk functions