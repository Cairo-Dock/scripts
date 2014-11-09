#!/bin/bash

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m"
ROUGE="\\033[1;31m"

#if ! test -d debian; then
#	echo -e "$ROUGE""'debian' dir doesn't exist""$NORMAL"
elif ! test -d ubuntu; then
	echo -e "$ROUGE""'ubuntu' dir doesn't exist""$NORMAL"
fi

echo -e "$BLEU""Structure which is needed to launch the script:""$NORMAL""
\t|-(debian) # no longer needed for this script
\t|-----|-Incoming
\t|-----|-----|-cairo-dock
\t|-----|-----|-cairo-dock-plug-ins
\t|-ubuntu
\t|-----|-Incoming
\t|-----|-----|-cairo-dock
\t|-----|-----|-cairo-dock-plug-ins
\n* ""$ROUGE""Deb packages have to be downloaded before! ""$NORMAL"
echo -e "$VERT""Continue ? [O/n]""$NORMAL"
read continuer
if test "$continuer" = "n" -o  "$continuer" = "N"; then
	exit 0
fi

#echo -e "$BLEU""\tDebian repository\n""$NORMAL"
#	cd debian/
#	echo -e "$ROUGE""Without debian...""$NORMAL"
#	./debian.sh -p

echo -e "$BLEU""\tUbuntu repository\n""$NORMAL"
	cd ../ubuntu/
	./ubuntu.sh -p

echo -e "$VERT""End""$NORMAL"
	cd ../
