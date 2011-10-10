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
    
    testCmd="${sut} -v config=${config} ${input} | diff -B ${expected} -"
    result=$(eval "${testCmd}")
    
    if [[ ${result} == "" ]]
    then
        echo "  ✓ ${testCase}"
    else
        differences=$(echo ${result} | wc -l)
        
        echo "  ✗ ${testCase} (see test/reports/${testCase}.report)"
        
        if [ ! -d  "test/reports" ]
        then
            mkdir "test/reports"
        fi
        
        echo "${result}" > "test/reports/${testCase}.report"
    fi
done