#! /usr/bin/env sh

function abspath {
  case "${1}" in
	[./]*)
	echo "$(cd ${1%/*}; pwd)/${1##*/}"
	;;
	*)
	echo "${PWD}/${1}"
	;;
  esac
}

function exitWithUsage {
	echo "Usage: ${0} <script dir> <testCase dir>" 
	exit 1
}

function exitWithError {
	echo "Error: ${1}" 
	exit 1
}

[ "${1}" == "" ] && exitWithUsage
[ "${2}" == "" ] && exitWithUsage
[ ! -d "${1}" ] && exitWithError "${1} is not a directory"
[ ! -d "${2}" ] && exitWithError "${2} is not a directory"

scriptDir=${1}
testCaseDir=${2}

echo "Running Tests:"

# This is used to handle file paths with spaces in the name.
# I'm not sure of how to do it any other way.

IFS=">"

for sutDir in ${testCaseDir}/*
do

	echo ${sutDir}
	for testDir in ${sutDir}/*
	do
		testCaseName="$(basename ${testDir})"
	
		report="$(abspath $(dirname ${0}))/failures/$(basename ${sutDir})/${testCaseName}.report"
		mkdir -p "$(dirname ${report})"
	
		result=$(${scriptDir}/$(basename ${sutDir}) -v configFile="${testDir}/config" "${testDir}/input" | \
			diff -u -B --suppress-common-lines "${testDir}/expected" - 2> "${report}")
		
		if [[ ${result} == "" ]]
		then
			echo "    ✓ ${testCaseName}"
			rm "${report}" &> /dev/null
		else
			echo "    ✗ ${testCaseName} (see ${report})"]
			echo "${result}" > "${report}"

			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
			echo "${result}"
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		fi
	done
done

find "$(dirname ${0})/failures" -type d -empty -exec rmdir {} + &> /dev/null || true
find "$(dirname ${0})/failures" -type d -empty -exec rmdir {} + &> /dev/null || true

unset IFS