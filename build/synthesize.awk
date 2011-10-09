#! /usr/bin/env awk -f

BEGIN {
    # @start-fragment default-config
    config["SYNTHESIZERS_SHOULD_BE_FORMATTED"]   = 1
    config["SYNTHESIZERS_SHOULD_HAVE_N_COLUMNS"] = 1
    # @end-fragment default-config
    
    if (configFile) {
        readConfig(configFile)
    }
    if (verbose) {
        printConfig(config)
    }
}
{
    if ($0 ~ /^[ \t]*@synthesize/ || $0 == "\n") {
        # @start-fragment body
        formatSynthesizeStatements()
        # @end-fragment body
    }
}

# @start-fragment functions
function formatSynthesizeStatements() {
    i = 1
    i = storeSynthesizedProperty(names, aliases, i)

    while (getline) {
        if ($0 ~ /^[ \t]*@synthesize/ || $0 == "\n") {
            i = storeSynthesizedProperty(names, aliases, i)
        } 
        else {
            maxNameLength = 0

            for (j = 1; j < i; j++) {
                maxNameLength = max(maxNameLength, length(names[j]))
            }

            format = "@synthesize %-" maxNameLength "s = %s;\n"

            for (j = 1; j < i; j++) {
                printf(format, names[j], aliases[j])
            }

            break
        }
    }
}

function storeSynthesizedProperty(names, aliases, i) {
    sub("@synthesize", "", $0)
    sub(";", "", $0)

    declarationCount = split($0, declarations,  ",")

    for (j = 1; j <= declarationCount; j++) {
        if (split(declarations[j], values, "=") < 2) {
            sub(" ", "", values[1])
            names[i] = values[1]
            aliases[i] = values[1]
        }
        else {
            sub(" ", "", values[1])
            sub(" ", "", values[2])

            names[i] = values[1]
            aliases[i] = values[2]
        }

        i++
    }

    return i
}

# @end-fragment functions


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

