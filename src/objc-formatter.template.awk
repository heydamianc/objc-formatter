#! /usr/bin/env awk -f
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright © 2011, Damian Carrillo
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#	list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, 
#	this list of conditions and the following disclaimer in the documentation 
#	and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the names of its contributors 
#	may be used to endorse or promote products derived from this software 
#	without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY 
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File:    objc-formatter.awk
# Version: 0.1
# Date:    2011-10-28
# 
# DESCRIPTION
#   Formats Objective-C source code and header files.
#
# Usage:
#   $ ./objc-formatter.awk [-v verbose=1] [-v configFile=<config file>] <source file>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BEGIN {

	# Possible values: 0, 1
	#
	#   0: Do not replace leading tabs charactes wth spaces
	#
	#   1: Replace all leading tab characters with spaces
	config["REPLACE_LEADING_TABS_WITH_SPACES"] = 1

	# Possible Values 0+
	#
	config["NUMBER_OF_SPACES_PER_TAB"] = 4


	# Possible values: 0, 1
	#
	#   0: Do not reformat properties.  All configuration entries that begin with 'PROPERTIES'
	#      will be ignored
	#   1: Reformat properties.  All configuration entries that begin with 'PROPERTIES' will
	#      be respected
	#
	config["PROPERTIES_SHOULD_BE_FORMATTED"] = 1

	# @include-fragment property.awk default-config

	# Possible values: 0, 1
	#
	#   0: Do not reformat synthesizers.  All configuration entries that begin with 'SYNTHESIZERS'
	#      will be ignored
	#   1: Reformat synthesizers.  All configuration entries that begin with 'SYNTHESIZERS' will
	#      be respected
	#
	config["SYNTHESIZERS_SHOULD_BE_FORMATTED"] = 1

	# Possible values: 0, 1
	#
	#   0: Do not reformat method declarations.
	#
	#   1: Reformat method declarations.
	#
	config["METHOD_DECLARATIONS_SHOULD_BE_FORMATTED"] = 1

	# @include-fragment synthesize.awk default-config

	# @include-fragment util.awk config

	tabReplacement = ""
	numberOfSpacesPerTab = config["NUMBER_OF_SPACES_PER_TAB"]

	for (i = 0; i < numberOfSpacesPerTab; i++) {
		tabReplacement = tabReplacement " "
	}

	while (getline line) {
		parseLine(line)
	}
}

function parseLine(line) {
	if (config["PROPERTIES_SHOULD_BE_FORMATTED"] == 1 && line ~ /@property/) {
		# @include-fragment property.awk parse
	} else if (config["SYNTHESIZERS_SHOULD_BE_FORMATTED"] == 1 && line ~ /@synthesize/) {
		# @include-fragment synthesize.awk parse
	} else if (config["METHOD_DECLARATIONS_SHOULD_BE_FORMATTED"] == 1 && line ~ /^[ \t]*-[ \t]*(.+)[ \t]*(.+)/) {
		#@include-fragment method.awk parse
	} else {
		line = trimTrailingWhitespace(line)
		line = detab(line, tabReplacement)
		print line
	}
}

# @include-fragment property.awk functions
# @include-fragment synthesize.awk functions
# @include-fragment method.awk functions
# @include-fragment util.awk functions