#!/bin/bash

#
# programming_languages_helper.sh
#

N=99
if [ "$1" == "O" ] ; then
	while read -r I ; do
		echo "$I" > /dev/null
	done  < <(seq 1 $N)
elif [ "$1" == "B" ] ; then
	while read -r I ; do
		(echo "$I") > /dev/null
	done  < <(seq 1 $N)
elif [ "$1" == "C" ] ; then
	while read -r I ; do
		./HelloC "World$I" > /dev/null
	done  < <(seq 1 $N)
elif [ "$1" == "R" ] ; then
	while read -r I ; do
		./HelloRust "World$I" > /dev/null
	done  < <(seq 1 $N)
elif [ "$1" == "G" ] ; then
	while read -r I ; do
		./HelloGraal "World$I" > /dev/null
	done  < <(seq 1 $N)
elif [ "$1" == "J" ] ; then
	while read -r I ; do
		java -cp . HelloJava "World$I" > /dev/null
	done  < <(seq 1 $N)
else
	echo "RTFM" >&2
fi
