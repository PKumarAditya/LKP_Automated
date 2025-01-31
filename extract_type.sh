#!/bin/bash

full_test_case="lkp run /home/amd/lkp-tests/splits/unixbench-100%-300s-int.yaml"

# Extract the portion after "/splits/"
test_case_string=$(echo "$full_test_case" | sed -E 's/.*\/splits\///')

# Extract the test name (before the first hyphen)
test=$(echo "$test_case_string" | awk -F'-' '{print $1}')

# Extract the type (everything after the first hyphen and before ".yaml")
type=$(echo "$test_case_string" | sed -E 's/^[^-]+-(.*)\.yaml/\1/')


cd /lkp/result/$test/$type/
find ./ -name *.time > /root/time
# Output the results
echo "Test Name: $test, Type: $type"

