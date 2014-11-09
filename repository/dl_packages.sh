#!/bin/bash

# from?
PPA="matttbe/experimental"  ## <---
#PPA="matttbe/experimental-debian-build"  ## <---
#PPA="cairo-dock-team/ppa"  ## <---

# to?
VERSION="ubuntu" # " debian"  ## <---

# what?
PKG="cairo-dock cairo-dock-plug-ins"  ## <---
#PKG="cairo-dock-plug-ins"  ## <---
FILTER="3\.2\.1-0ubuntu"
#FILTER="3\.0\.0\.1-1ubuntu3"

######### GO ##########

for i in $VERSION; do
	rm -rf $i/Incoming
	mkdir -p $i/Incoming/cairo-dock $i/Incoming/cairo-dock-plug-ins
	cd $i/Incoming/
	for k in $PKG; do
		cd $k
		DL="http://ppa.launchpad.net/$PPA/ubuntu/pool/main/c/$k/"
		wget $DL
		for j in `grep deb index.html | grep "$FILTER" | grep "\.deb" |cut -d\" -f8`; do wget -c $DL$j; done
		rm index.html
		cd ..
		#PPA=$PPA_DEBIAN
	done
	cd ../../
	PPA=$PPA_DEBIAN
done
