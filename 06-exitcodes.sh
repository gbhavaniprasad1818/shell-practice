#!/bin/bash

all_success=true

# 1. Run ls /tmp
ls /tmp > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "SUCCESS"
else
    echo "FAILURE"
    all_success=false
fi

# 2. Run ls /fakedir
ls /fakedir > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "SUCCESS"
else
    echo "FAILURE"
    all_success=false
fi

# 3. Ping google.com
ping -c1 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Host reachable"
else
    echo "Host not reachable"
    all_success=false
fi

# 4. Exit with appropriate code
if [ "$all_success" = true ]; then
    echo "All commands succeeded"
    exit 0
else
    echo "One or more commands failed"
    exit 1
fi