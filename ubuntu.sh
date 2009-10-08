#!/bin/sh

Ubuntu_Distrib="hardy intrepid jaunty karmic"
Architecture="i386 amd64 lpia"
#Version_CD=`cairo-dock --version`
#read -p "La version de CD ? Par exemple '`cairo-dock --version`' :" Version_CD

GPGHome=$HOME/.gnupg/

echo "Disposition des paquets deb et leur dsc :
\t|-dists
\t|-----|-distrib (-> $Ubuntu_Distrib)
\t|-----|-----|-pool
\t|-----|-----|-----|-cairo-dock
\t|-----|-----|-----|-cairo-dock-plug-ins
\t|-----|-----|-----|-(webkit) => hardy
Depot pour Ubuntu :
\tversions : $Ubuntu_Distrib
\tarchitectures : $Architecture
\nContinuer ? [Y/n]"
read pause
if test "$pause" = "n" -o  "$pause" = "N"; then
	exit 0
fi

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
	
	for archi in $Architecture
	do
		echo "Generation des fichiers necessaires au depot pour Ubuntu $distrib - Architecture : $archi" 
		Dir=$MainDir/cairo-dock/binary-$archi
		mkdir $Dir

		# create index for each distribution and architecture
		echo "\tGeneration des fichiers d'index pour Ubuntu $distrib - Architecture : $archi" 
		apt-ftparchive packages $PoolDir > $Dir/Packages
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
	gpg --sign -bao $MainDir/Release.gpg $MainDir/Release
done
# end.
