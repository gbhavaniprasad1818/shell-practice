#!/bin/bash

FREE_SPACE=$(free -mt | grep "Total" | awk '{print $4}')
THRESHOLD=500

echo "Free Memory: $FREE_SPACE MB"

if [[ $FREE_SPACE -lt $TH ]]
then
	echo "WARNING, RAM is running low"
else
	echo "RAM Space is sufficient - $FREE_SPACE MB"
fi

if [[ $FREE_SPACE -lt $TH ]]; then
    echo "Warning: Free memory is low"
else
    echo "Free memory is sufficient - $FREE_SPACE MB."
fi
