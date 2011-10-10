#! /usr/bin/env awk -f

BEGIN {
    # @start-fragment default-config
    config["SYNTHESIZERS_SHOULD_BE_FORMATTED"]   = 1
    config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] = 1
    # @end-fragment default-config
    
    # @include-fragment util.awk config
}
{
    if ($0 ~ /@synthesize/) {
        # @start-fragment body
		readSynthesizeBlock(properties, aliases)
		formatSynthesizeBlock(properties, aliases)
        # @end-fragment body
    }
}

# @start-fragment functions

function readSynthesizeBlock(properties, aliases) {
	do {
		foundSemicolon = 0
		do {
			foundSemicolon = extractSynthesizers(properties, aliases)			
		}
		while (foundSemicolon == 0 && getline > 0)
	} while (getline > 0 && $0 ~ /@synthesize/)
}

function extractSynthesizers(properties, aliases) {
	foundSemicolon = index($0, ";")
	
	gsub("@synthesize", "", $0)
	gsub(/[ \t]+/, "", $0)
	sub(/,$/, "", $0)
	sub(/;$/, "", $0)
	
	split($0, synthesizeStatements, ",")
	
	for (i = 1; i <= length(synthesizeStatements); i++) {
		split(synthesizeStatements[i], components, "=")
		
		propertyCount = length(properties)
		
		properties[propertyCount + 1] = components[1]
		aliases[propertyCount + 1] = components[length(components)]
	}

	return foundSemicolon
}

function formatSynthesizeBlock(properties, aliases) {
	maxLength = 0

	for (i = 1; i <= length(properties); i++) {
		maxLength = max(maxLength, length(properties[i]));
	}
	
	for (i = 1; i <= length(properties); i++) {
		format = ""
		
		if (config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] == 1) {
			format = "@synthesize %s = %s;\n"
		} else {
			format = "@synthesize %-" maxLength "s = %s;\n"
		}
		
		printf(format, properties[i], aliases[i])
	}
}

# @end-fragment functions

# @include-fragment util.awk functions