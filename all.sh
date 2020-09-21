#!/bin/bash

#
# all.sh
#

if ! [[ "$(pwd)" =~ .*shcompare\.github\.io$ ]] ; then
	echo "RTFM" >&2
	exit 1
fi
while read -r F ;do
	O="$(echo "$F" | perl -pe 's/\.sh/.json/g')"
	echo bash "$F" \> "$O"
	bash "$F" > "$O"
done < <(find . -name '*.sh' | grep -v "all.sh")
