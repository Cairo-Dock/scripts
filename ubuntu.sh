#!/bin/sh

Arg=$1
Ubuntu_Distrib="hardy intrepid jaunty karmic"
Architecture="i386 amd64 lpia"


## Fonctions ##

dossiers() {
	if test -d dists; then
		read -p "Supprimer le dossier Dists ? (o/N)" RmDists
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
		if test "$distrib" = "hardy"; then
			mkdir $PoolDir/all/webkit
		fi
		for archi in $Architecture
		do
			mkdir $PoolDir/$archi
			mkdir $PoolDir/$archi/cairo-dock
			mkdir $PoolDir/$archi/cairo-dock-plug-ins
			if test "$distrib" = "hardy"; then
				mkdir $PoolDir/$archi/webkit
			fi
		done
	done
}

depot() {
	for distrib in $Ubuntu_Distrib
	do
		MainDir=dists/$distrib
		PoolDir=$MainDir/pool
		case $distrib in
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
			echo "Generation des fichiers necessaires au depot pour Ubuntu $distrib - Architecture : $archi" 
			Dir=$MainDir/cairo-dock/binary-$archi
			mkdir $Dir

			# create index for each distribution and architecture
			echo "\tGeneration des fichiers d'index pour Ubuntu $distrib - Architecture : $archi" 
			apt-ftparchive packages $PoolDir/all > $Dir/Packages
			apt-ftparchive packages $PoolDir/$archi >> $Dir/Packages
			cat $Dir/Packages | gzip -9c > $Dir/Packages.gz
			cat $Dir/Packages | bzip2 > $Dir/Packages.bz2
		
			echo "\tGeneration du fichier Release propre a la distribution et à l'archi"
			#rm -f $Dir/Release*
			Date=`date`
			echo "Archive: $distrib" >> $Dir/Release
			echo "Version: $Version_distrib" >> $Dir/Release
			echo "Components: cairo-dock" >> $Dir/Release
			echo "Origin: Cairo-Dock Team" >> $Dir/Release
			echo "Label: Ubuntu" >> $Dir/Release
			echo "Architectures: $archi" >> $Dir/Release
			echo "\t\tFichiers genere"
		done

		# create Release file
		echo "\n\tGeneration du fichier Release propre a la distribution"
		#rm -f $MainDir/Release*
		Date=`date`
		echo "Origin: Cairo-Dock Team" >> $MainDir/Release
		echo "Label: Ubuntu" >> $MainDir/Release
		echo "Suite: $distrib" >> $MainDir/Release
		echo "Version: $Version_distrib" >> $MainDir/Release
		echo "Codename: $distrib" >> $MainDir/Release
		echo "Date: $Date" >> $MainDir/Release
		echo "Architectures: $Architecture" >> $MainDir/Release
		echo "Components: cairo-dock" >> $MainDir/Release
		echo "Description: $Description_distrib" >> $MainDir/Release

		echo "\tGeneration des MD5, SHA1 et SHA256 dans le release principal"
		apt-ftparchive release $MainDir >> $MainDir/Release

		echo "\tGeneration du fichier Release.gpg\n\n"
		# sign Release file
		$MainDir/Release.gpg
		gpg --sign -u 41317877 -bao $MainDir/Release.gpg $MainDir/Release
	done
}

## Main ##

echo "Disposition des paquets deb et leur dsc :
\t|-dists
\t|-----|-distrib (-> $Ubuntu_Distrib)
\t|-----|-----|-pool
\t|-----|-----|-----|-all
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
\t|-----|-----|-----|-----|-(webkit) => hardy
\t|-----|-----|-----|-architecture (-> $Architecture)
\t|-----|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-----|-cairo-dock-plug-ins
\t|-----|-----|-----|-----|-(webkit) => hardy
Depot pour Ubuntu :
\tversions : $Ubuntu_Distrib
\tarchitectures : $Architecture
\nContinuer [O] / Créer ces dossiers [d] / Stop [n] ?"
read pause
if test "$pause" = "n" -o  "$pause" = "N"; then
	exit 0
elif test "$pause" = "d" -o  "$pause" = "D"; then
	dossiers
else
	depot
fi

exit 0
