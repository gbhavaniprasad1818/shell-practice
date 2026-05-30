#!/bin/bash

FREE_SPACE=$(free -mt | grep "Total" | awk '{print $4}')
echo "Free Memory: $FREE_SPACE MB"

if [ [ $FREE_SPACE -lt $TH ] ]; then
    echo "Warning: Free memory is low"
else
    echo "Free memory is sufficient - $FREE_SPACE MB."
fi

