#! /usr/bin/env sh

if [ "${1}" == "" ]
then
    echo "Usage:" ${0} "test.dir"
    exit 1
fi

testDir="${1}"

for testCase in $(ls ${testDir})
do
    sut="${testDir}/${testCase}/sut"
    config="${testDir}/${testCase}/config"
    input="${testDir}/${testCase}/input"
    expected="${testDir}/${testCase}/expected"
    
    testCmd="${sut} -v config=${config} ${input} | diff --side-by-side ${expected} -"
    
    echo "${testCmd}"
    output=$(eval "${testCmd}")
    echo "${output}"

done