#!/bin/bash
ARG1=$1
DIR=$(pwd) # -> /opt/cairo-dock_bzr/Paquets/*.*.*

DIR_VERIF=`echo $DIR | grep -c /Paquets/`

UBUNTU_CORE="karmic jaunty intrepid hardy debian"
UBUNTU_PLUG_INS="karmic jaunty intrepid hardy debian"
CL="debian/changelog"
ARG_CONFIGURE="--enable-network-monitor --enable-rssreader --enable-scooby-do"
DPUT_PSEUDO="matttbe"

### CHANGELOG ###
CHANGELOG='\\n  * New Upstream Version (sync from BZR).'
CHANGELOG_PLUG_INS='\\n  * New Upstream Version (sync from BZR).'

#	## Pour dput.cf :
#	  * remplacer 'matttbe' ci-dessous et ci-dessus par votre pseudo
#	  * Avoir plusieurs entrées pour les versions supportées (voir ci-dessus sauf pour debian)
#		[matttbe-exp-jaunty] 
#		fqdn = ppa.launchpad.net 
#		method = ftp 
#		incoming = ~matttbe/experimental/ubuntu/jaunty
#		login = anonymous 
#		allow_unsigned_uploads = 0 
#
#		[matttbe-jaunty] 
#		fqdn = ppa.launchpad.net 
#		method = ftp 
#		incoming = ~matttbe/ppa/ubuntu/jaunty 
#		login = anonymous 
#		allow_unsigned_uploads = 0

#	## Explications
#	  * Attention de bien respecter la disposition des dossiers (ou modifier le script)
#	  * Les paquets sont envoyés sur son propre ppa pour être ensuite copier vers les ppa de CD (obligé à cause des 2 tarball à envoyer par version...
#	  * Le script doit être exécuté depuis le dossier Paquets/x.x.x/ => .././paquets-CD.sh


TRAP_ON='echo -e "\e]0;$BASH_COMMAND\007"' # Afficher la commande en cours dans le terminal
TRAP_OFF="trap DEBUG"
date_AJD=`date '+%Y%m%d'`

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m"
ROUGE="\\033[1;31m"

##### Main #####

echo -e "$VERT""Upload sur les ppa\n""$NORMAL"

echo -e "$BLEU""Disposition :""$NORMAL""
\t|-/cairo-dock-core (+ sources)
\t|-/cairo-dock-plug-ins (+ sources)
\t|-/debian (+ sources)
\t|-/Paquets
\t|-----|-/x.x.x -> (par ex : 2.1.0)
\t|-----|-----|- => le script est lancé depuis ce dossier"
echo -e "$BLEU""PPA :""$NORMAL""
\t* Avoir deux ppa
\t* Ajouter DEBFULLNAME= et DEBEMAIL= en fonction de la clé choisie dans le ~/.bashrc
\t* Avoir un fichier ~/.dput.cf avec pseudo-version et pseudo-exp-version (ex dans ce script)"

if test "$ARG1" = ""; then
	echo -e "$BLEU""\nExtras :""$NORMAL""
\tSi le script est lancé avec '../.paquets-CD.sh -...' :
\t\t-e : ./configure --prefix=/usr $ARG_CONFIGURE
\t\t-f : pas de autoreconf ni ./configure"
fi

if [ $DIR_VERIF -eq 0 ]; then
	echo -c "$ROUGE""ATTENTION : Mauvais dossier ! ""$NORMAL"
	exit 0
fi

NUMBER_RELEASE=`cat ../../cairo-dock-core/configure.ac | head -n5 | grep INIT | cut -d[ -f3 | cut -d] -f1` # 2.1.0-rc3
NUMBER_RELEASE_PG=`cat ../../cairo-dock-plug-ins/configure.ac | head -n5 | grep INIT | cut -d[ -f3 | cut -d] -f1` # 2.1.0-rc3
PLUG_INS=`cat ../../cairo-dock-plug-ins/configure.ac | head -n5 | grep INIT | cut -d[ -f2 | cut -d] -f1` # cairo-dock-plugins

echo -e "$VERT"

read -p "Version spéciale ? (sinon : $NUMBER_RELEASE-$date_AJD-0ubuntu1~ppa0 ; 'CD' = Version pour les dépôts) : " VERSION
# trickle
	dpkg -s trickle |grep installed |grep "install ok" > /dev/null	
	if [ $? -eq 1 ]; then
		echo -e "$ROUGE""Le paquet 'trickle' n'est pas installé : Installation""$NORMAL"
		sudo apt-get install -qq trickle 
	fi
read -p "Limite de l'upload (en ko) : " TRICKLE
if [ "$TRICKLE" = "" ]; then
	TRICKLE=0
fi

if test "$ARG1" = "-t"; then
	echo -e "$ROUGE""NOT Generating tarballs ...""$NORMAL"
	mv *.tar.gz ../
fi

if test ! "$ARG1" = "-u"; then
	read -p "Le dossier courant va être vider de son contenu, pressez Enter pour continuer" POUET
	rm -r *
fi
echo -e "$NORMAL"

date > $DIR/log.txt

###### TARBALL ######
if test "$ARG1" = "-t"; then
	mv ../*.tar.gz .
	tar xzf *.tar.gz
elif test "$ARG1" = "-u"; then
	echo -e "$ROUGE""Uniquement l'upload""$NORMAL"
else

	echo "***************************"
	echo -e "* ""$VERT""Generating tarballs ...""$NORMAL"" *"
	echo "***************************"

	echo -e "$VERT""\n\tCore""$NORMAL"
	echo -e "\n\t==== Tarball : Core ====\n" >> $DIR/log.txt
	cd ../../cairo-dock-core/
	trap "$TRAP_ON" DEBUG
	if [ "$ARG1" = "-f" ]; then
		echo -e "$ROUGE""no autoreconf + configure""$NORMAL"
	else
		autoreconf -isvf >> $DIR/log.txt
		./configure --prefix=/usr >> $DIR/log.txt
	fi
	make dist >> $DIR/log.txt
	$TRAP_OFF
	TARBALL_CORE="cairo-dock-$NUMBER_RELEASE.tar.gz"
	TARBALL_ORIG_CORE="cairo-dock-$NUMBER_RELEASE.orig.tar.gz"
	mv $TARBALL_CORE $DIR/$TARBALL_ORIG_CORE
	cd $DIR
	tar xzf $TARBALL_ORIG_CORE

	echo -e "$VERT""\tPlug-ins""$NORMAL"
	echo -e "\n\t==== Tarball : Plug-ins ====\n" >> $DIR/log.txt
	cd ../../cairo-dock-plug-ins/
	if [ $NUMBER_RELEASE != $NUMBER_RELEASE_PG ]; then
		echo -e "$ROUGE""ATTENTION, la version est différente de core""$NORMAL"
	fi
	trap "$TRAP_ON" DEBUG
	if [ "$ARG1" = "-f" ]; then
		echo -e "$ROUGE""no autoreconf + configure""$NORMAL"
	elif [ "$ARG1" = "-e" ]; then
		echo -e "$ROUGE""./configure $ARG_CONFIGURE""$NORMAL"
		autoreconf -isvf >> $DIR/log.txt
		./configure --prefix=/usr $ARG_CONFIGURE >> $DIR/log.txt
	else
		autoreconf -isvf >> $DIR/log.txt
		./configure --prefix=/usr >> $DIR/log.txt
	fi
	make dist >> $DIR/log.txt
	$TRAP_OFF
	TARBALL_PG="$PLUG_INS-$NUMBER_RELEASE_PG.tar.gz"
	TARBALL_ORIG_PG="$PLUG_INS-$NUMBER_RELEASE_PG.orig.tar.gz"
	mv $TARBALL_PG $DIR/$TARBALL_ORIG_PG
	cd $DIR
	tar xzf $TARBALL_ORIG_PG
fi

### PACKAGE NAME

if [ "$VERSION" = "" ]; then
	VERSION="$NUMBER_RELEASE-$date_AJD-0ubuntu1~ppa0"
	VERSION_PG="$NUMBER_RELEASE_PG-$date_AJD-0ubuntu1~ppa0"
	VERSION_DEB="$NUMBER_RELEASE-$date_AJD-1debian1~ppa0"
	VERSION_DEB_PG="$NUMBER_RELEASE_PG-$date_AJD-1debian1~ppa0"
elif [ "$VERSION" = "CD" ]; then
	VERSION="$NUMBER_RELEASE-1ubuntu1"
	VERSION_PG="$NUMBER_RELEASE_PG-1ubuntu1"
	VERSION_DEB="$NUMBER_RELEASE"
	VERSION_DEB_PG="$NUMBER_RELEASE_PG"
else
	VERSION_PG=$VERSION
	VERSION_DEB=$VERSION
	VERSION_DEB_PG=$VERSION
fi

cd $DIR/cairo-dock-$NUMBER_RELEASE

###### CORE ######
echo -e "$BLEU""\nEnvoie des paquets Core\n""$NORMAL"

for RLS in $UBUNTU_CORE; do
	echo -e "$VERT""Envoie des paquets Core - $RLS""$NORMAL"
	echo -e "\n\t==== Upload : Core - $RLS ====" >> $DIR/log.txt
	if test -d 'debian'; then
		rm -r debian
	fi
	cp -r ../../../debian/$RLS/debian .
	if test "$RLS" = "debian"; then
		PAQUET="cairo-dock ($VERSION_DEB~$RLS) jaunty; urgency=low"
	else
		PAQUET="cairo-dock ($VERSION~$RLS) $RLS; urgency=low"
	fi
	DATE=`date -R`
	SIGN='\\n -- '"$DEBFULLNAME <$DEBEMAIL>"'  '"$DATE \n"
	sed -i "1i$SIGN" $CL
	sed -i "1i$CHANGELOG" $CL
	sed -i "1i$PAQUET" $CL
	trap "$TRAP_ON" DEBUG
	debuild -S -sa >> $DIR/log.txt
	if test "$RLS" = "debian"; then
		trickle -u $TRICKLE dput $DPUT_PSEUDO-jaunty ../cairo-dock_"$VERSION_DEB"~"$RLS"_source.changes
	else
		trickle -u $TRICKLE dput $DPUT_PSEUDO-exp-$RLS ../cairo-dock_"$VERSION"~"$RLS"_source.changes
	fi
	$TRAP_OFF
done



###### PLUG-INS ######

cd $DIR/$PLUG_INS-$NUMBER_RELEASE_PG
echo -e "$BLEU""\nEnvoie des paquets Plug-ins\n""$NORMAL"

for RLS in $UBUNTU_PLUG_INS; do
	echo -e "$VERT""\nEnvoie des paquets Plug-ins - $RLS""$NORMAL"
	echo -e "\n\t==== Upload : Plug-ins - $RLS ====\n" >> $DIR/log.txt
	if test -d 'debian'; then
		rm -r debian
	fi
	cp -r ../../../debian/$RLS/plug-ins/debian .
	if test "$RLS" = "hardy"; then
		PAQUET_PLUG_INS="cairo-dock-plug-ins ($VERSION_PG~$RLS) intrepid; urgency=low"
	elif test "$RLS" = "debian"; then
		PAQUET_PLUG_INS="cairo-dock-plug-ins ($VERSION_DEB_PG~$RLS) jaunty; urgency=low"
	else
		PAQUET_PLUG_INS="cairo-dock-plug-ins ($VERSION_PG~$RLS) $RLS; urgency=low"
	fi
	DATE=`date -R`
	SIGN='\\n -- '"$DEBFULLNAME <$DEBEMAIL>"'  '"$DATE \n"
	sed -i "1i$SIGN" $CL
	sed -i "1i$CHANGELOG_PLUG_INS" $CL
	sed -i "1i$PAQUET_PLUG_INS" $CL
	trap "$TRAP_ON" DEBUG
	debuild -S -sa >> $DIR/log.txt
	if test "$RLS" = "hardy"; then
		trickle -u $TRICKLE dput $DPUT_PSEUDO-intrepid ../cairo-dock-plug-ins_"$VERSION_PG"~"$RLS"_source.changes
	elif test "$RLS" = "debian"; then
		trickle -u $TRICKLE dput $DPUT_PSEUDO-jaunty ../cairo-dock-plug-ins_"$VERSION_DEB_PG"~"$RLS"_source.changes
	else
		trickle -u $TRICKLE dput $DPUT_PSEUDO-exp-$RLS ../cairo-dock-plug-ins_"$VERSION_PG"~"$RLS"_source.changes
	fi
	$TRAP_OFF
done

zenity --info --title=Cairo-Dock --text="Le script d'envoie des paquets est terminé"
echo -e "\n\t==== FIN ====" >> $DIR/log.txt

exit
