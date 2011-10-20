#! /usr/bin/env awk -f

BEGIN {
	# @start-fragment default-config
	# Possible Values: 0, 1
	#
	#   0: Does not group IBOutlets at the top of all property declarations
	#
	#   1: Groups all IBOutlets at the top of all property declarations
	# 
	config["PROPERTIES_SHOULD_HAVE_IBOUTLETS_GROUPED"] = 1

	# Possible Values: 0, 1
	#
	#	0: @property(nonatomic, retain) UIViewController *viewController;
	#
	#	1: @property (nonatomic, retain) UIViewController *viewController;
	#
	config["PROPERTIES_SHOULD_HAVE_SPACE_AFTER_ANNOTATION"] = 1

	# Possible Values: 1 - 4
	#
	#   1: All property declarations shift as far left as possible
	#      @property(nonatomic, retain) IBOutlet UIWindow *window;
	#      @property(nonatomic, retain, readwrite) UITableView *tableView;
	#
	#   2: All property annotations are left aligned, all following information is left aligned
	#      @property(nonatomic, retain)            IBOutlet UIWindow *window;
	#      @property(nonatomic, retain, readwrite) UITableView *tableView;
	#
	#   3: All property annotations are left aligned, then all decorators and types are considered
	#      as being a single column, then all names are lined up
	#      @property(nonatomic, retain)            IBOutlet UIWindow *window;
	#      @property(nonatomic, retain, readwrite) UITableView       *tableView;
	#
	#   4: All property annotations are left aligned, then all decorators, types, and names are 
	#      lined up in a columnar fashion
	#      @property(nonatomic, retain)            IBOutlet UIWindow    *window;
	#      @property(nonatomic, retain, readwrite)          UITableView *tableView;
	#
	config["PROPERTIES_SHOULD_HAVE_N_COLUMNS"] = 4
	# @end-fragment default-config

	# @include-fragment util.awk config

	while (getline line) {
		parseLine(line)
	}
}

function parseLine(line) {
	if (line ~ /@property/) {
		# @start-fragment parse
		maxLengths["propertyDeclaration"] = 0
		maxLengths["decoratorList"]       = 0
		maxLengths["type"]                = 0
		maxLengths["name"]                = 0

		readProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths)
		# @end-fragment parse
	}
}

# @start-fragment functions
function readProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths) {
	extractProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths)
	getline line

	if (line ~ /@property/ || line ~ /^[ \t]*$/) {
		readProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths)
	} else {
		formatProperties(propertyDeclarations, decoratorLists, types, names, maxLengths)
		parseLine(line)
	}
}

function extractProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths) {
	if (line !~ /^[ \t]*$/) {
		gsub(";", "", line)
		line = condenseWhitespace(line)
		
		propertyLength = index(line, ")")
		
		if (propertyLength == 0) {
			propertyLength = 9 # length of "@property"
		}

		propertyDeclaration = substr(line, 0, propertyLength)
		sub(/@property[ \t]*\(/, "@property(", propertyDeclaration)

		i = length(propertyDeclarations) + 1

		propertyDeclaration = trim(propertyDeclaration)
		maxLengths["propertyDeclaration"] = max(maxLengths["propertyDeclaration"], length(propertyDeclaration))
		propertyDeclarations[i] = propertyDeclaration

		variableDeclaration = trim(substr(line, propertyLength + 1, length(line)))

		# associate the star with the variable name's token
		gsub(/[ \t]*\*[ \t]*/, " *", variableDeclaration)

		split(variableDeclaration, variableComponents)

		variableComponentCount = length(variableComponents)

		name = trim(variableComponents[variableComponentCount])
		maxLengths["name"] = max(maxLengths["name"], length(name))
		names[i] = name

		type = trim(variableComponents[variableComponentCount - 1])
		maxLengths["type"] = max(maxLengths["type"], length(type))
		types[i] = type

		decoratorList = ""

		for (j = 1; j < variableComponentCount - 1; j++) {
			decoratorList = decoratorList " " variableComponents[j]
		}

		decoratorList = trim(condenseWhitespace(decoratorList))
		decoratorLists[i] = decoratorList
		maxLengths["decoratorList"] = max(maxLengths["decoratorList"], length(decoratorList))
	}
}

function formatProperties(propertyDeclarations, decoratorLists, types, names, maxLengths) {
	propertyCount = length(propertyDeclarations)

	if (config["PROPERTIES_SHOULD_HAVE_IBOUTLETS_GROUPED"] == 1) {
		a = 1
		b = 1

		for (i = 1; i <= propertyCount; i++) {
			if (decoratorLists[i] ~ /IBOutlet/) {
				propertyDeclarationsA[a] = propertyDeclarations[i]
				decoratorListsA[a]       = decoratorLists[i]
				typesA[a]                = types[i]
				namesA[a]                = names[i]

				a++
			} else {
				propertyDeclarationsB[b] = propertyDeclarations[i]
				decoratorListsB[b]       = decoratorLists[i]
				typesB[b]                = types[i]
				namesB[b]                = names[i]

				b++
			}
		}

		delete propertyDeclarations
		delete decoratorLists
		delete types
		delete names

		j = 1

		propertiesInA = length(propertyDeclarationsA)
		for (a = 1; a <= propertiesInA; a++) {
			propertyDeclarations[j] = propertyDeclarationsA[a]
			decoratorLists[j]       = decoratorListsA[a]
			types[j]                = typesA[a]
			names[j]                = namesA[a]

			j++
		}

		propertiesInB = length(propertyDeclarationsB)
		for (b = 1; b <= propertiesInB; b++) {
			propertyDeclarations[j] = propertyDeclarationsB[b]
			decoratorLists[j]       = decoratorListsB[b]
			types[j]                = typesB[b]
			names[j]                = namesB[b]

			j++
		}
	}

	if (config["PROPERTIES_SHOULD_HAVE_SPACE_AFTER_ANNOTATION"] == 1) {
		for (i = 1; i <= propertyCount; i++) {
			sub(/@property\(/, "@property (", propertyDeclarations[i])
		}

		maxLengths["propertyDeclaration"] = maxLengths["propertyDeclaration"] + 1
	}

	# precalculate the 2nd column's length (for the case when there are 3 columns)

	col2Len = 0
	for (i = 1; i < propertyCount; i++) {
		col2Len = max(col2Len, length(trim(decoratorLists[i] " " types[i] " ")))
	}

	for (i = 1; i <= propertyCount; i++) {
		if (config["PROPERTIES_SHOULD_HAVE_N_COLUMNS"] == 1) {
			if (length(decoratorLists[i]) > 0) {
				printf("%s %s %s %s;\n", propertyDeclarations[i], decoratorLists[i], types[i], names[i])
			} else {

				printf("%s %s %s;\n", propertyDeclarations[i], types[i], names[i])
			}
		} else if (config["PROPERTIES_SHOULD_HAVE_N_COLUMNS"] == 2) {
			col1 = propertyDeclarations[i]
			col2 = trim(decoratorLists[i] " " types[i] " " names[i])

			format = "%-" maxLengths["propertyDeclaration"] "s %s;\n"

			printf(format, col1, col2)
		} else if (config["PROPERTIES_SHOULD_HAVE_N_COLUMNS"] == 3) {
			col1 = propertyDeclarations[i]
			col2 = trim(decoratorLists[i] " " types[i] " ")
			col3 = names[i]

			format = "%-" maxLengths["propertyDeclaration"] "s %-" col2Len "s %s;\n"
			printf(format, col1, col2, col3)
		} else {
			col1 = propertyDeclarations[i]
			col2 = decoratorLists[i]
			col3 = types[i]
			col4 = names[i]

			if (maxLengths["decoratorList"] == 0) {
				format = "%-" maxLengths["propertyDeclaration"] "s %-" maxLengths["type"] "s %s;\n"
				printf(format, col1, col3, col4)
			} else {
				format = "%-" maxLengths["propertyDeclaration"] "s %-" maxLengths["decoratorList"] "s " \
					"%-" maxLengths["type"] "s %s;\n"
				printf(format, col1, col2, col3, col4)
			}
		}
	}

	print ""
}
# @end-fragment functions

# @include-fragment util.awk functions