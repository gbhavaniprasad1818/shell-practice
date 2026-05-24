#!/bin/bash

Timestamp=$(date)
echo "Current date and time: $Timestamp"
CurrentTime=$(date +"%T")
echo "Current time: $CurrentTime"
CurrentDate=$(date +"%D")
echo "Current date: $CurrentDate"

START_TIME=$(date +%s)
# Simulate a task that takes some time (e.g., sleep for 5 seconds)
sleep 5
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
echo "Total execution time: $TOTAL_TIME seconds"