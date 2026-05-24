#!/bin/bash
echo "ls /tmp running"
ls /tmp

if [ $? -ne 0 ]; then 
    echo "ls /tmp is FAILED"
exit 1
else
    echo "ls /tmp is SUCCESS"
fi

echo "ls /fakeddir running"
ls /fakeddir

if [ $? -ne 0 ]; then 
    echo "ls /fakeddir is FAILED"
exit 1
else
    echo "ls /fakeddir is SUCCESS"
fi


