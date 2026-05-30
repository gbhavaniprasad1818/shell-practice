#!/bin/bash

# This script is used to archive files in the current directory.

# give the path of the directory where you want to archive files
#---------------------------------------------------------------
BASE=/c/devops/repos 

DAYS=30 # 30days files will be archived 
DEPTH=1
RUN=0

#CHECK IF THE DIRECTORY EXISTS
#------------------------------

if [ ! -d "$BASE" ]; then
  echo "Directory $BASE does not exist."
    exit 1
fi

# create archive directory if it does not present
#------------------------------------------------

if [ ! -d "$BASE/archive" ]; then
  mkdir "$BASE/archive"
fi

# Find the list of files larger than 20MB
#----------------------------------------

find i in 'find "$BASE" -maxdepth $DEPTH -type f -size +20M

 do
  if [ $RUN -eq 0 ]; then
        echo "[ $(date "+%Y-%m-%d %H:%M:%S") ] Archiving $i ==> $BASE/archive
        gzip $i || exit 1
        mv $i.gz $BASE/archive || exit 1
  fi 
done

