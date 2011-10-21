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

for sutDir in ${testCaseDir}/*
do
	sut="${scriptDir}/$(basename ${sutDir})"
	echo "  ${sut}"

	testScript=$(abspath "${scriptDir}/$(basename ${sutDir})")

	for testCase in ${sutDir}/*
	do
		config=$(abspath ${testCase}/config)
		input=$(abspath ${testCase}/input)
		expected=$(abspath ${testCase}/expected)

		testCaseName="$(basename ${testCase})"

		report="$(abspath $(dirname ${0}))/failures/$(basename ${sutDir})/${testCaseName}.report"
		mkdir -p "$(dirname ${report})"

		result=$(eval "${testScript} -v configFile=\"${config}\" \"${input}\" | diff -u -B --suppress-common-lines \"${expected}\" - 2> \"${report}\"")

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

find "$(dirname ${0})/failures" -type d -empty -exec rmdir {} +
find "$(dirname ${0})/failures" -type d -empty -exec rmdir {} +
