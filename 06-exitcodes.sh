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



echo "ping google.com running"
ping -c1 google.com

if [ $? -eq 0 ]; then
    echo "Host reachable"

else
    echo "Host not reachable"
fi


if [ $? -eq 0 ]; then
    echo " exit 0"
else
    cho " exit 1"
fi
