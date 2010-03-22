#!/bin/sh

ARG1=$1
Debian_Distrib="stable unstable"
Architecture="i386 amd64 lpia"
CD_key="41317877"

debug_mv="cp"


## Fonctions ##

dossiers() {
	if test -d dists; then
		read -p "Supprimer le dossier 'dists' ? (o/N)" RmDists
		if test "$RmDists" = "o" -o  "$RmDists" = "O"; then
			rm -r dists
		fi
	fi
	mkdir dists
	for distrib in $Debian_Distrib
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

paquets() {
	if ! test -d Incoming; then
		echo "Il faut respecter cette structure :
		|-Incoming
		|-----|-cairo-dock
		|-----|-cairo-dock-plug-ins"
		read -p "Créer ces dossiers (O) / Continuer (c) / Stop (s) ?" paquets_suite
		if test "$paquets_suite" = "c" -o  "$paquets_suite" = "C"; then
			paquets_question
		elif test "$paquets_suite" = "s" -o  "$paquets_suite" = "S"; then
			echo "Stop"
			exit 0
		else
			mkdir -p Incoming/cairo-dock
			mkdir Incoming/cairo-dock-plug-ins
			echo "\tIl faut placer les paquets deb dedans et relancer le script"
			exit 0
		fi
	fi

	if test -d dists; then
		read -p "Supprimer le dossier 'dists' ? (o/n)" RmDists
		if test "$RmDists" = "n" -o  "$RmDists" = "N"; then
			echo "Stop"
			exit 0
		fi
		rm -r dists
	fi
	dossiers

	echo "Déplacement des paquets :"
	for distrib in $Debian_Distrib
	do
		if [ "$distrib" = "stable" ]; then
			distrib2="debian2"
		else
			distrib2="debian"
		fi
		MainDir=dists/$distrib
		PoolDir=$MainDir/pool
		echo "\t$distrib"
			# all
		$debug_mv Incoming/cairo-dock/cairo-dock_*~$distrib2*_all.deb $PoolDir/all/cairo-dock
		$debug_mv Incoming/cairo-dock/cairo-dock-dev_*~$distrib2*_all.deb $PoolDir/all/cairo-dock
		$debug_mv Incoming/cairo-dock/cairo-dock-data_*~$distrib2*_all.deb $PoolDir/all/cairo-dock
		$debug_mv Incoming/cairo-dock-plug-ins/cairo-dock-plug-ins-data_*~$distrib2*_all.deb $PoolDir/all/cairo-dock-plug-ins
		for archi in $Architecture
		do
			$debug_mv Incoming/cairo-dock/cairo-dock-core_*~$distrib2*_$archi.deb $PoolDir/$archi/cairo-dock
			$debug_mv Incoming/cairo-dock-plug-ins/cairo-dock-plug-ins_*~$distrib2*_$archi.deb $PoolDir/$archi/cairo-dock-plug-ins
			$debug_mv Incoming/cairo-dock-plug-ins/cairo-dock-plug-ins-integration_*~$distrib2*_$archi.deb $PoolDir/$archi/cairo-dock-plug-ins
		done
	done
}

depot() {
	echo "Création des fichiers release et Packages"
	for distrib in $Debian_Distrib
	do
		echo "\tDebian $distrib" 
		MainDir=dists/$distrib
		PoolDir=$MainDir/pool
		case $distrib in
			stable)
				Version_distrib="5.0"
				Description_distrib="Debian Stable 5.0"
				;;
			unstable)
				Version_distrib="6.0"
				Description_distrib="Debian Unstable 6.0"
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
			Date=`date`
			echo "Archive: $distrib" > $Dir/Release
			echo "Version: $Version_distrib" >> $Dir/Release
			echo "Components: cairo-dock" >> $Dir/Release
			echo "Origin: Cairo-Dock Team" >> $Dir/Release
			echo "Label: Debian" >> $Dir/Release
			echo "Architectures: $archi" >> $Dir/Release
		done

		# create Release file
		echo "\n\t\tRelease : $distrib"
		Date=`date`
		echo "Origin: Cairo-Dock Team" > $MainDir/Release
		echo "Label: Debian" >> $MainDir/Release
		echo "Suite: $distrib" >> $MainDir/Release
		echo "Version: $Version_distrib" >> $MainDir/Release
		echo "Codename: $distrib" >> $MainDir/Release
		echo "Date: $Date" >> $MainDir/Release
		echo "Architectures: $Architecture" >> $MainDir/Release
		echo "Components: cairo-dock" >> $MainDir/Release
		echo "Description: $Description_distrib" >> $MainDir/Release

		echo "\t\t\tMD5, SHA1 et SHA256 : $distrib"
		apt-ftparchive release $MainDir >> $MainDir/Release

		echo "\t\t\tRelease.gpg : $distrib\n\n"
		# sign Release file
		gpg --sign -u $CD_key -bao $MainDir/Release.gpg $MainDir/Release
	done
}

paquets_question() {
	paquets
	read -p "Créer les fichiers release et Packages ? [O/n]" suite
	if test "$suite" = "n" -o  "$suite" = "N"; then
		echo "Stop"
		exit 0
	fi
	depot
}

## Main ##

if [ "$ARG1" = "-p" ]; then
	paquets
	depot
else
	echo "Disposition des paquets deb :
\t|-dists
\t|-----|-'distrib' (-> $Debian_Distrib)
\t|-----|-----|-pool
\t|-----|-----|-----|-all
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
\t|-----|-----|-----|-'architecture' (-> $Architecture)
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
Possibilité de les arranger automatiquement si on a :
\t|-Incoming
\t|-----|-cairo-dock
\t|-----|-cairo-dock-plug-ins
Depot pour Debian :
\tversions : $Debian_Distrib
\tarchitectures : $Architecture

Créer release et Packages [O] / Créer les dossiers de dists [d]
 Déplacer les paquets Incoming -> dists [p] / Stop [n]\t\t=> [O/d/p/n]"
	read pause
	if test "$pause" = "n" -o  "$pause" = "N"; then
		exit 0
	elif test "$pause" = "d" -o  "$pause" = "D"; then
		dossiers
	elif test "$pause" = "p" -o  "$pause" = "P"; then
		paquets_question
	else
		depot
	fi
fi
