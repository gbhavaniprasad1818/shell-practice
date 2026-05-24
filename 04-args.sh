#!/bin/bash

PERSON1="Siva"
PERSON2="INDIA"
echo "User $PERSON1 is from $PERSON2"
echo "Number of arguments: $#"
echo "All arguments: $*"
echo "Script name: $0"

# sh 04-args.sh siva india -> User siva is from india
# Number of arguments: 2
# All arguments: siva india
# Script name: 04-args.sh

