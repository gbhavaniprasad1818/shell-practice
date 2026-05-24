#!/bin/bash

if [ $? -eq 0 ]; then
    echo "ls /tmp executed successfully."
else
    echo "ls /tmp failed to execute."

if [ $? -ne 0 ]; then 
    echo "ls /tmp is FAILED"
exit 1
else
    echo "ls /tmp is SUCCESS"
fi
fi

if [ $? -eq 0 ]; then
    echo "ls /fakeddir executed successfully."
else
    echo "ls /fakeddir failed to execute."

if [ $? -ne 0 ]; then 
    echo "ls /fakeddir is FAILED"
exit 1
else
    echo "ls /fakeddir is SUCCESS"
fi
fi
