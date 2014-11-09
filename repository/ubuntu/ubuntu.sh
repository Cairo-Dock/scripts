#!/bin/sh

ARG1=$1
Ubuntu_Distrib="lucid oneiric precise quantal raring"
# added the new distrib => l108
Architecture="i386 amd64 "
CD_key="41317877"
## LUCID => no LPIA
debug_mv="cp"	# move files (mv) or just copy them (cp)


## functions ##

directories() {
	if test -d dists; then
		read -p "Remove 'dists' dir? (o/N)" RmDists
		if test "$RmDists" = "o" -o  "$RmDists" = "O"; then
			rm -r dists
		fi
	fi
	mkdir dists
	for distrib in $Ubuntu_Distrib
	do
		MainDir=dists/$distrib
		mkdir $MainDir
		PoolDir=$MainDir/pool
		mkdir $PoolDir
		mkdir $PoolDir/all
		mkdir $PoolDir/all/cairo-dock
		mkdir $PoolDir/all/cairo-dock-plug-ins
		for archi in $Architecture
		do
			mkdir $PoolDir/$archi
			mkdir $PoolDir/$archi/cairo-dock
			mkdir $PoolDir/$archi/cairo-dock-plug-ins
		done
	done
}

packages() {
	if ! test -d Incoming; then
		echo "You need to respect this tree:
		|-Incoming
		|-----|-cairo-dock
		|-----|-cairo-dock-plug-ins"
		read -p "Create these dirs (O) / Continue (c) / Stop (s) ?" packages_next
		if test "$packages_next" = "c" -o  "$packages_next" = "C"; then
			packages_questions
		elif test "$packages_next" = "s" -o  "$packages_next" = "S"; then
			echo "Stop"
			exit 0
		else
			mkdir -p Incoming/cairo-dock
			mkdir Incoming/cairo-dock-plug-ins
			echo "\tYou need to move deb packages in it and relaunch the script"
			exit 0
		fi
	fi

	if test -d dists; then
		read -p "Remove 'dists' dir? (o/n)" RmDists
		if test "$RmDists" = "n" -o  "$RmDists" = "N"; then
			echo "Stop"
			exit 0
		fi
		rm -r dists
	fi
	directories

	echo "Move packages:"
	for distrib in $Ubuntu_Distrib
	do
		MainDir=dists/$distrib
		PoolDir=$MainDir/pool
		echo "\n\t$distrib"
			# all
		$debug_mv Incoming/cairo-dock/*~"$distrib"_all.deb $PoolDir/all/cairo-dock
		$debug_mv Incoming/cairo-dock-plug-ins/*~"$distrib"_all.deb $PoolDir/all/cairo-dock-plug-ins
		for archi in $Architecture
		do
			$debug_mv Incoming/cairo-dock/*~"$distrib"_$archi.deb $PoolDir/$archi/cairo-dock
			$debug_mv Incoming/cairo-dock-plug-ins/*~"$distrib"_$archi.deb $PoolDir/$archi/cairo-dock-plug-ins
		done
	done
}

repository() {
	echo "Creating release and Packages files"
	for distrib in $Ubuntu_Distrib
	do
		echo "\tUbuntu $distrib" 
		MainDir=dists/$distrib
		PoolDir=$MainDir/pool
		Version_distrib="unstable"
		Description_distrib="Ubuntu Unstable"
		case $distrib in
			raring)
				Version_distrib="13.04"
				Description_distrib="Ubuntu Raring 13.04"
				;;
			quantal)
				Version_distrib="12.10"
				Description_distrib="Ubuntu Quantal 12.10"
				;;
			precise)
				Version_distrib="12.04"
				Description_distrib="Ubuntu Precise 12.04"
				;;
			oneiric)
				Version_distrib="11.10"
				Description_distrib="Ubuntu Oneiric 11.10"
				;;
			natty)
				Version_distrib="11.04"
				Description_distrib="Ubuntu Natty 11.04"
				;;
			maverick)
				Version_distrib="10.10"
				Description_distrib="Ubuntu Maverick 10.10"
				;;
			lucid)
				Version_distrib="10.04"
				Description_distrib="Ubuntu Lucid 10.04"
				;;
			karmic)
				Version_distrib="9.10"
				Description_distrib="Ubuntu Karmic 9.10"
				;;
			jaunty)
				Version_distrib="9.04"
				Description_distrib="Ubuntu Jaunty 9.04"
				;;
			intrepid)
				Version_distrib="8.10"
				Description_distrib="Ubuntu Intrepid 8.10"
				;;
			hardy)
				Version_distrib="8.04"
				Description_distrib="Ubuntu Hardy 8.04"
				;;
		esac
		mkdir $MainDir/cairo-dock/
	
		for archi in $Architecture
		do
			echo "\t\tArchitecture : $archi" 
			Dir=$MainDir/cairo-dock/binary-$archi
			mkdir $Dir

			# create index for each distribution and architecture
			echo "\t\t\tPackages - $archi" 
			apt-ftparchive packages $PoolDir/all > $Dir/Packages
			apt-ftparchive packages $PoolDir/$archi >> $Dir/Packages
			cat $Dir/Packages | gzip -9c > $Dir/Packages.gz
			cat $Dir/Packages | bzip2 > $Dir/Packages.bz2
		
			echo "\t\t\tRelease - $archi"
			echo "Archive: $distrib" > $Dir/Release
			echo "Version: $Version_distrib" >> $Dir/Release
			echo "Components: cairo-dock" >> $Dir/Release
			echo "Origin: Cairo-Dock Team" >> $Dir/Release
			echo "Label: Ubuntu" >> $Dir/Release
			echo "Architectures: $archi" >> $Dir/Release
		done

		# create Release file
		echo "\n\t\tRelease : $distrib"
		echo "Origin: Cairo-Dock Team" > $MainDir/../Release_$distrib
		echo "Label: Ubuntu" >> $MainDir/../Release_$distrib
		echo "Suite: $distrib" >> $MainDir/../Release_$distrib
		echo "Version: $Version_distrib" >> $MainDir/../Release_$distrib
		echo "Codename: $distrib" >> $MainDir/../Release_$distrib
		echo "Architectures: $Architecture" >> $MainDir/../Release_$distrib
		echo "Components: cairo-dock" >> $MainDir/../Release_$distrib
		echo "Description: $Description_distrib" >> $MainDir/../Release_$distrib

		echo "\t\t\tMD5, SHA1 et SHA256 : $distrib"
		apt-ftparchive release $MainDir >> $MainDir/../Release_$distrib
		mv $MainDir/../Release_$distrib $MainDir/Release

		echo "\t\t\tRelease.gpg : $distrib\n\n"
		# sign Release file
		gpg --sign -u $CD_key -bao $MainDir/Release.gpg $MainDir/Release
	done
}

packages_questions() {
	packages
	read -p "Create release and Packages files? [O/n]" suite
	if test "$suite" = "n" -o  "$suite" = "N"; then
		echo "Stop"
		exit 0
	fi
	repository
}

## Main ##

if [ "$ARG1" = "-p" ]; then
	packages
	repository
else
	echo "Structure needed for a repository:
\t|-dists
\t|-----|-'distrib' (-> $Ubuntu_Distrib)
\t|-----|-----|-pool
\t|-----|-----|-----|-all
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
\t|-----|-----|-----|-'architecture' (-> $Architecture)
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
Possibility to automatically create this tree if we have all deb packages in:
\t|-Incoming
\t|-----|-cairo-dock
\t|-----|-cairo-dock-plug-ins
Repository for Ubuntu:
\tversions : $Ubuntu_Distrib
\tarchitectures : $Architecture

Create release and Packages [O] / Just create directories in dists [d]
 Move packages from Incoming -> dists [p] / Stop [n]\t\t=> [O/d/p/n]"
	read pause
	if test "$pause" = "n" -o  "$pause" = "N"; then
		exit 0
	elif test "$pause" = "d" -o  "$pause" = "D"; then
		directories
	elif test "$pause" = "p" -o  "$pause" = "P"; then
		packages_questions
	else
		repository
	fi
fi
