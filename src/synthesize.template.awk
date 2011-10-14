#! /usr/bin/env awk -f

BEGIN {
    # @start-fragment default-config
    config["SYNTHESIZERS_SHOULD_BE_FORMATTED"]   = 1
    config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] = 2
    # @end-fragment default-config
    
    # @include-fragment util.awk config

    # @start-fragment body
    while (getline line) {
        parseLine(line)
    }
    # @end-fragment body
}

# @start-fragment functions

function parseLine(line) {
    if (line ~ /@synthesize/) {
        readSynthesizers(line, properties, aliases)
    }
}

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
        parseLine(line)
    }
}

function extractSynthesizers(line, properties, aliases) {
    gsub("@synthesize", "", line)
    gsub(";", "", line)
    gsub(/[ \t]*/, "", line)
    
    split(line, individualProperties, ",")
    
    for (i = 1; i <= length(individualProperties); i++) {
        split(individualProperties[i], components, "=")
        
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