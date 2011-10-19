#! /usr/bin/env awk -f

BEGIN {
	# @start-fragment default-config
	config["PROPERTIES_SHOULD_BE_FORMATTED"] = 1
	
	# Possible Values: 0, 1
	#
	#	0: @property(nonatomic, retain) UIViewController *viewController;
	#
	#	1: @property (nonatomic, retain) UIViewController *viewController;
	#
	config["PROPERTIES_SHOULD_HAVE_SPACE_AFTER_ANNOTATION"] = 0
	
	# Possible Values: 1 - 4
	#
	#	1: All property declarations shift as far left as possible
	#	   @property(nonatomic, retain) IBOutlet UIWindow *window;
	#	   @property(nonatomic, retain, readwrite) UITableView *tableView;
	#
	#	2: All property annotations are left aligned, all following information is left aligned
	#	   @property(nonatomic, retain)			   IBOutlet UIWindow *window;
	#	   @property(nonatomic, retain, readwrite) UITableView *tableView;
	#
	#	3: All property annotations are left aligned, then all decorators and types are considered
	#	   as being a single column, then all names are lined up
	#	   @property(nonatomic, retain)			   IBOutlet UIWindow *window;
	#	   @property(nonatomic, retain, readwrite) UITableView		 *tableView;
	#
	#	4: All property annotations are left aligned, then all decorators, types, and names are 
	#	   lined up in a columnar fashion
	#	   @property(nonatomic, retain)			   IBOutlet UIWindow	*window;
	#	   @property(nonatomic, retain, readwrite)			UITableView *tableView;
	#
	config["PROPERTIES_SHOULD_HAVE_N_COLUMNS"] = 1
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
	if (line ~ /@property/) {
		maxLengths["propertyDeclaration"] = 0
		maxLengths["decoratorList"]       = 0
		maxLengths["type"]                = 0
		maxLengths["name"]                = 0
		
		readProperties(line, propertyDeclarations, decoratorLists, types, names, maxLengths)
	}
}

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
		
		rightParensLoc = index(line, ")")
		
		propertyDeclaration = substr(line, 0, rightParensLoc)
		sub(/@property[ \t]*\(/, "@property(", propertyDeclaration)

		i = length(propertyDeclarations) + 1

		propertyDeclaration = trim(propertyDeclaration)
		maxLengths["propertyDeclaration"] = max(maxLengths["propertyDeclaration"], length(propertyDeclaration))
		propertyDeclarations[i] = propertyDeclaration
		
		variableDeclaration = trim(substr(line, rightParensLoc + 1, length(line)))

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
		}
	}
}

# @end-fragment functions

# @include-fragment util.awk functions