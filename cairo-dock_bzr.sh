#!/bin/bash

# Script for BZR install for Cairo-Dock
#
# Copyright : (C) 2009 by Yann SLADEK
# E-mail : mav@cairo-dock.org
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# http://www.gnu.org/licenses/licenses.html#GPL


#Changelog
# 22/01/10 : 	matttbe : changement pour DBus applets + traduction
# 08/11/09 : 	matttbe : Prise en charge de Lucid + applets third-party
# 25/10/09 : 	matttbe : ajout de RSSreader + scooby-do + envoie des info via ShowDialog
# 16/10/09 : 	matttbe : Contrôle de la connexion Internet
# 14/10/09 : 	matttbe : Ajout du support pour Linux Mint
# 18/09/09 : 	matttbe : on enlève le lanceur devenu inutile.
# 16/09/09 : 	nochka85 : Fix du message si on n'a jamais installé le dock par paquet
#		matttbe : fix erreur au reload
# 15/09/09 : 	matttbe : ajout du dépôt debian et hardy + désinstallation des paquets de CD si installation par bzr.
#		boucle pour ajouter des arguments, par ex './cairo-dock_bzr.sh -e "scooby-do"'. L'autre méthode est tjs ok.
#		+ curl dans les dep + reload auto en cas de nouvelle version
# 13/09/09 : 	matttbe : ajout de mail et NM à compiler
#		possibilité d'ajouter d'autres arguments avec, par exemple  './cairo-dock_bzr.sh -e "--enable-scooby-do"'
# 08/09/09 : 	matttbe : fix de libxklavier, fix de revno, réduction des passphrases
#		possibilité de choisir bzr branch ou bzr checkout et d'installer les depôts weekly
#		Menu différent si le dossier cairo-dock-core existe ou non
#		On 'force' l'installation des paquets
#		Ajout du menu avec -o et -c
#		Fix pour branch => il faut d'abord se trouver dans le dossier !
# 06/09/09 : 	Modification du script pour gérér BZR
# 16/05/09 : 	Suppression de stacks
# 15/05/09 : 	Suppression des themes, ajout de dnd2share et modification de la detection de la distrib (smo)
# 18/04/09 :	Suppression de l'installation de Glitz (inutile depuis la v2)
# 16/11/08 : 	Refonte du script pour la version 2
# 13/11/08 :	Mise à jour des versions de cairo, glitz et pixman (pas de mises à jour auto)
# 22/10/08 :	Ajout de intrepid dans la détection des distribs
# 23/05/08 :	Ajout de la détection de la distrib et des plugins correspondant
# 20/05/08 : 	Ajout du choix du mode compilation (--full-compile pour forcer l'autoreconf)
# 28/03/08 : 	Ajout de l'icone pour XFCE et KDE (en test)
#				Suppression de l'icone lors de la désinstall
#				Téléchargement et recompilation de tous les plugins à chaque mise à jour de cairo-dock (en une passe)
# 25/03/08 : 	Ajout de l'applet Switcher pour test :)
# 22/03/08 :	Ajout de l'icone Cairo-Dock SVN dans le menu Applications de Gnome (uniquement)
# 20/03/08 :	Ajout des themes dans une branches séparés
# 16/02/08 : 	Ajout des paquets libxxf86vm-dev et libx11-dev danss les dépendances
# 12/02/08 : 	Ajout de la fonction de desinstallation de Glitz
#				Modification de la fonction de vérification des erreurs lors de l'install

DEBUG=0 # Attention, ne pas oublier de modifier !!!
DIR=$(pwd)
LOG_CAIRO_DOCK=$DIR/log.txt
SCRIPT="cairo-dock_bzr.sh"
SCRIPT_SAVE="cairo-dock_bzr.sh.save"
SCRIPT_NEW="cairo-dock_bzr.sh.new"
HOST="http://svn.cairo-dock.org"
DOMAIN="cairo-dock.org"

CAIRO_DOCK_CORE_LP_BRANCH="cairo-dock-core"
CAIRO_DOCK_PLUG_INS_LP_BRANCH="cairo-dock-plug-ins"
CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH="cairo-dock-plug-ins-extras"
CAIRO_DOCK_PLUG_INS_EXTRAS_USR="/usr/share/cairo-dock/plug-ins/Dbus/third-party"
CAIRO_DOCK_PLUG_INS_EXTRAS_HOME="$HOME/.config/cairo-dock/third-party"

#unset SSH_AUTH_SOCK # Evite de devoir retaper le passphrase
# ssh-add

#PLUGINS="alsaMixer Animated-icons Cairo-Penguin Clipper clock compiz-icon Dbus desklet-rendering dialog-rendering dnd2share dock-rendering drop-indicator dustbin GMenu icon-effect illusion keyboard-indicator logout mail motion-blur musicPlayer netspeed Network-Monitor powermanager quick-browser rhythmbox Scooby-Do shortcuts showDesklets showDesktop show-mouse slider stack System-Monitor switcher systray terminal tomboy Toons weather weblets wifi Xgamma xmms"
PLUGINS_GNOME="gnome-integration"
PLUGINS_GNOME_OLD="gnome-integration-old"
PLUGINS_XFCE="xfce-integration"

NEEDED="bzr libtool build-essential automake1.9 autoconf m4 autotools-dev pkg-config zenity intltool gettext libcairo2-dev libgtk2.0-dev librsvg2-dev libdbus-glib-1-dev libgnomeui-dev libvte-dev libxxf86vm-dev libx11-dev libalsa-ocaml-dev libasound2-dev libxtst-dev libgnome-menu-dev libgtkglext1-dev freeglut3-dev glutg3-dev libetpan-dev libwebkit-dev libexif-dev curl "
NEEDED_XFCE="libthunar-vfs-1-dev"
NEEDED_GNOME="libgnomevfs2-dev"
NEEDED_KARMIC="libxklavier-dev"
NEEDED_B_KARMIC="libxklavier12-dev"

UPDATE=0
UPDATE_PLUG_INS=0
UPDATE_CAIRO_DOCK=0
ERROR=0
FULL_COMPILE=0
DISTRIB=""
INSTALL_CAIRO_DOCK_OK=1
CONFIGURE="--enable-network-monitor --enable-rssreader --enable-scooby-do"

if test -e "$DIR/.bzr_dl"; then
	BZR_DL_MODE=`cat $DIR/.bzr_dl`
else
	BZR_DL_MODE=0
fi

BZR_REV_FILE_CORE="$DIR/.bzr_core"
BZR_REV_FILE_PLUG_INS="$DIR/.bzr_plug_ins"
BZR_REV_FILE_PLUG_INS_EXTRAS="$DIR/.bzr_plug_ins_extras"

TRAP_ON='echo -e "\e]0;$BASH_COMMAND\007"' # Afficher la commande en cours dans le terminal
TRAP_OFF="trap DEBUG"

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m" 
ROUGE="\\033[1;31m"


#######################################################################
#	Fonctions d'install
#######################################################################

install_cairo_dock() {

	rm -Rf $LOG_CAIRO_DOCK > /dev/null

	echo "Installation de Cairo-Dock du `date`" >> $LOG_CAIRO_DOCK

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation : Cairo-Dock Core"

	install_cairo >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
		check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}

install_cairo() {
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH

	autoreconf -isvf && ./configure --prefix=/usr && make clean && make -j $(grep -c ^processor /proc/cpuinfo)

	if [ $? -ne 0 ]; then
		return 1
	fi

	sudo make install
	cd ..
}


install_cairo_dock_plugins() {

	echo -e "$BLEU""Installation : Plug-Ins"

	echo "Installation des plug-ins du `date`" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK

	install_plugins >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}


install_plugins() {
	echo $(pwd)

	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
	echo $(pwd)

	autoreconf -isvf && ./configure --prefix=/usr $CONFIGURE && make clean && make -j $(grep -c ^processor /proc/cpuinfo)
	
	if [ $? -ne 0 ]; then
		return 1
	fi

	sudo make install
	cd ..
}


install_cairo_dock_plugins_extras() {
	echo -e "$BLEU""Installation : Plug-ins Extras"

	echo "Installation des Plug-ins Extras du `date`" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK
	
	mkdir -p $CAIRO_DOCK_PLUG_INS_EXTRAS_HOME # ça ne coute rien -> dossiers parents

	for i in `ls $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH`;do
		rm -rf $CAIRO_DOCK_PLUG_INS_EXTRAS_HOME/$i # on vire ceux que l'on va remplacer
	done

	cp -R $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH/* $CAIRO_DOCK_PLUG_INS_EXTRAS_HOME/ >> $LOG_CAIRO_DOCK 2>&1
	rm -rf $CAIRO_DOCK_PLUG_INS_EXTRAS_HOME/.bzr $CAIRO_DOCK_PLUG_INS_EXTRAS_HOME/demos

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}



install(){
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""C'est la première fois que vous installez la version BZR de Cairo-Dock"
		echo -e "\nGrâce à l'outil bzr, vous pouvez désormais télécharger les sources de plusieurs façons, notamment télécharger tout le contenu de la branche (si vous souhaitez ultérieurement procéder à des modifications et les publier sur des branches différents) ou uniquement la dernière révision (si vous voulez simplement tester les dernières révisions)\n""$VERT"

		BZR_DL_READ='0' # il nous faut une boucle pour prendre plus de cas
		while [ $BZR_DL_READ != '1' ] && [ $BZR_DL_READ != '2' ]; do
			echo -e "\t1 --> Télécharger la branche complète (~150Mo - pour les développeurs)"
			echo -e "\t2 --> Télécharger la dernière version (~20Mo - pour tous utilisateurs)"
			read BZR_DL_READ 
		done

		case $BZR_DL_READ in
			"1")
				echo -e "Mode choisi : branch\n"
				BZR_DL="branch"
				BZR_DL_MODE=1
			;;
			"" | "2")
				echo -e "Mode choisi : checkout --lightweight\n"
				BZR_DL="checkout --lightweight -q"
				BZR_DL_MODE=0
			;;
		esac

		echo $BZR_DL_MODE > $DIR/.bzr_dl

		echo -e "$BLEU""Téléchargement des données. Cette opération peut prendre quelques minutes"
		LG_DL_BG="Téléchargement de"
		LG_DL_END="Données téléchargées. L'installation va débuter\nCette opération peut prendre plusieurs minutes et ralentir votre système"
		LG_DL_ERROR="Impossible de se connecter au serveur de Launchpad, veuillez vérifier votre connexion internet ou retenter plus tard"
	else
		echo -e "$BLEU""Is it the first time that you install Cairo-Dock from BZR sources files?"
		echo -e "\nWith BZR you can download these sources files in two ways:\n\t* By downloading all the content (it's interesting to have a copy of the server branch if you want to make some modifications in this branch) or only the latest revision (if you just want to compile sources)\n""$VERT"

		BZR_DL_READ='0'
		while [ $BZR_DL_READ != '1' ] && [ $BZR_DL_READ != '2' ]; do
			echo -e "\t1 --> Download the complete branch (~150Mo - for dev.)"
			echo -e "\t2 --> Download only the last rev. (~20Mo - for all users)"
			read BZR_DL_READ 
		done

		case $BZR_DL_READ in
			"1")
				echo -e "Your choice: 'branch'\n"
				BZR_DL="branch"
				BZR_DL_MODE=1
			;;
			"" | "2")
				echo -e "Your choice: 'checkout --lightweight'\n"
				BZR_DL="checkout --lightweight -q"
				BZR_DL_MODE=0
			;;
		esac

		echo $BZR_DL_MODE > $DIR/.bzr_dl

		echo -e "$BLEU""The download will begin. Please wait ;)"
		LG_DL_BG="Download of"
		LG_DL_END="Sources files downloaded. The installation will begin\nThis compilation can take some time and slow down your system"
		LG_DL_ERROR="It seems that there is some problems. Please check your Internet connexion or retry later!"
	fi

	echo -e "$NORMAL"
	sleep 2

	if [ ! -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Cairo-Dock Core"
		bzr $BZR_DL lp:$CAIRO_DOCK_CORE_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			exit
		else
			NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
			echo $NEW_CORE_VERSION > $BZR_REV_FILE_CORE
			echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n"
			echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS ##

	if [ ! -d $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins"
		bzr $BZR_DL lp:$CAIRO_DOCK_PLUG_INS_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			exit
		else
			NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
			echo $NEW_PLUG_INS_VERSION > $BZR_REV_FILE_PLUG_INS
			echo -e "\nCairo-Dock-Plug-ins : rev $NEW_PLUG_INS_VERSION \n"
			echo -e "\nCairo-Dock-Plug-ins : rev $NEW_PLUG_INS_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS EXTRAS ##

	if [ ! -d $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins Extras"
		bzr $BZR_DL lp:$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			exit
		else
			NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH`
			echo $NEW_PLUG_INS_EXTRAS_VERSION > $BZR_REV_FILE_PLUG_INS_EXTRAS
			echo -e "\nCairo-Dock-Plug-ins-Extras : rev $NEW_PLUG_INS_EXTRAS_VERSION \n"
			echo -e "\nCairo-Dock-Plug-ins-Extras : rev $NEW_PLUG_INS_EXTRAS_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL"
	echo -e "$BLEU""$LG_DL_END"
	echo -e "$NORMAL"

	sleep 5

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	check $LOG_CAIRO_DOCK "CD"
}


reinstall(){
	FULL_COMPILE=1

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	check $LOG_CAIRO_DOCK "CD"
}



#######################################################################
#	Fonctions de désinstallation
#######################################################################


uninstall() {
	echo "Désinstallation de Cairo-Dock et des plug-ins"

	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH
	sudo make uninstall > $LOG_CAIRO_DOCK 2>&1
	cd ..

	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..

	sudo rm -r $CAIRO_DOCK_PLUG_INS_EXTRAS_USR

	if [ -e /usr/share/applications/cairo-dock_svn.desktop ]; then
		sudo rm -f /usr/share/applications/cairo-dock_svn.desktop
	fi
	echo "La désinstallation à été effectuée / Uninstallation finished"
	echo ""
	echo "Cependant, votre dossier de configuration est toujours présent."
	echo "Celui-ci se trouve dans votre ~/.config et se nomme cairo-dock (attention c'est un dossier caché)."
	echo "Vous pouvez le supprimer une fois la désinstallation effectuée"
}



#######################################################################
#	Fonctions de mises à jour
#######################################################################

update(){
	if [ $LG -eq 0 ]; then
		LG_SEARCH_FOR="Recherche des mises à jour pour"
		LG_UP_FOUND="Une mise à jour a été détectée pour"
	else
		LG_SEARCH_FOR="Check if there is an update for"
		LG_UP_FOUND="An update has been detected for"
	fi

	echo -e "$BLEU""$LG_SEARCH_FOR Cairo-Dock"
	if test -e "$BZR_REV_FILE_CORE"; then
		ACTUAL_CORE_VERSION=`cat "$BZR_REV_FILE_CORE"`
	else
		echo 0 > "$BZR_REV_FILE_CORE"
		ACTUAL_CORE_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH
		BZR_UP="pull"
		bzr $BZR_UP lp:$CAIRO_DOCK_CORE_LP_BRANCH
		NEW_CORE_VERSION=`bzr revno -q`
		bzr log -l1 --line
		cd $DIR/
	else
		BZR_UP="update -q"
		NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
		if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_CORE_LP_BRANCH
		fi
	fi

	echo $NEW_CORE_VERSION > $BZR_REV_FILE_CORE
	echo -e "\nCairo-Dock-Core : rev $ACTUAL_CORE_VERSION -> $NEW_CORE_VERSION \n"
	echo -e "\nCairo-Dock-Core : rev $ACTUAL_CORE_VERSION -> $NEW_CORE_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
		echo -e "$VERT""$LG_UP_FOUND Cairo-Dock"
		sleep 1
		install_cairo_dock
		UPDATE_CAIRO_DOCK=1
		UPDATE=1
		#echo -e "$VERT""Mise à jour et recompilation des plug-ins suite à la mise à jour de cairo-dock"
		echo -e "$NORMAL"""
	else
		echo -e "$NORMAL"""
	fi

	## PLUG-INS ##

	echo -e "$BLEU""$LG_SEARCH_FOR Plug-ins"
	if test -e "$BZR_REV_FILE_PLUG_INS"; then
		ACTUAL_PLUG_INS_VERSION=`cat "$BZR_REV_FILE_PLUG_INS"`
	else
		echo 0 > "$BZR_REV_FILE_PLUG_INS"
		ACTUAL_PLUG_INS_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
		bzr $BZR_UP lp:$CAIRO_DOCK_PLUG_INS_LP_BRANCH
		NEW_PLUG_INS_VERSION=`bzr revno -q`
		bzr log -l1 --line
		cd $DIR/
	else
		NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
		if [ $ACTUAL_PLUG_INS_VERSION -ne $NEW_PLUG_INS_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		fi
	fi

	echo $NEW_PLUG_INS_VERSION > "$BZR_REV_FILE_PLUG_INS"
	echo -e "\nCairo-Dock-Plug-Ins : rev $ACTUAL_PLUG_INS_VERSION -> $NEW_PLUG_INS_VERSION \n"
	echo -e "\nCairo-Dock-Plug-Ins : rev $ACTUAL_PLUG_INS_VERSION -> $NEW_PLUG_INS_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_PLUG_INS_VERSION -ne $NEW_PLUG_INS_VERSION ]; then
		echo -e "$VERT""$LG_UP_FOUND Plug-Ins"
		install_cairo_dock_plugins
		UPDATE=1
	elif [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$VERT""Recompilation des plug-ins suite à la mise à jour de Cairo-Dock Core"
		else
			echo -e "$VERT""Recompilation due to some changes of Cairo-Dock API"
		fi
		install_cairo_dock_plugins
	fi
	echo -e "$NORMAL"

	## PLUG-INS EXTRAS ##

	echo -e "$BLEU""$LG_SEARCH_FOR Plug-ins Extras"
	if test -e "$BZR_REV_FILE_PLUG_INS_EXTRAS"; then # le fichier existe
		ACTUAL_PLUG_INS_EXTRAS_VERSION=`cat "$BZR_REV_FILE_PLUG_INS_EXTRAS"`
	else
		echo 0 > "$BZR_REV_FILE_PLUG_INS_EXTRAS"
		ACTUAL_PLUG_INS_EXTRAS_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		bzr $BZR_UP lp:$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q`
		bzr log -l1 --line
		cd $DIR/
	else
		NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH`
		if [ $ACTUAL_PLUG_INS_EXTRAS_VERSION -ne $NEW_PLUG_INS_EXTRAS_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		fi
	fi

	echo $NEW_PLUG_INS_EXTRAS_VERSION > "$BZR_REV_FILE_PLUG_INS_EXTRAS"
	echo -e "\nCairo-Dock-Plug-Ins-Extras : rev $ACTUAL_PLUG_INS_EXTRAS_VERSION -> $NEW_PLUG_INS_EXTRAS_VERSION \n"
	echo -e "\nCairo-Dock-Plug-Ins-Extras : rev $ACTUAL_PLUG_INS_EXTRAS_VERSION -> $NEW_PLUG_INS_EXTRAS_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_PLUG_INS_EXTRAS_VERSION -ne $NEW_PLUG_INS_EXTRAS_VERSION ]; then
		echo -e "$VERT""$LG_UP_FOUND Plug-Ins Extras"
		install_cairo_dock_plugins_extras
		UPDATE=1
	fi
  
	echo -e "$NORMAL"
    
 	if [ $UPDATE -eq 1 ]; then
	    check $LOG_CAIRO_DOCK "CD"
	else
		if [ $LG -eq 0 ]; then
			echo -e "$BLEU""Pas de mise à jour disponible"
			echo -e "$NORMAL"
			if [[ `ps aux | grep -e "[c]airo-dock -"` ]]; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Pas de mise à jour" int32:8 string:terminal string:any string:none
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		else
			echo -e "$BLEU""No update available"
			echo -e "$NORMAL"
			if [[ `ps aux | grep -e "[c]airo-dock -"` ]]; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: no update" int32:8 string:terminal string:any string:none
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		fi
		exit
	fi
}



#######################################################################
#	Fonctions de vérifications
#######################################################################

check() {
	if [ $LG -eq 0 ]; then
		echo -e "$NORMAL""Vérification de l'intégrité de l'installation"
		LG_INSTALL_OK="L'installation s'est terminée correctement."
	else
		echo -e "$NORMAL""Verification of the installation"
		LG_INSTALL_OK="Successfully installed"
	fi
	sleep 1

	if [ $2 = "CD" ]; then
		if [ $ERROR -ne 0 ]; then
			echo -e "$ROUGE"
			if [ $LG -eq 0 ]; then
				echo "Des erreurs ont été détéctées lors de l'installation."
				egrep -i "( error| Erreur)" $1
				echo "Veuillez consulter le fichier log.txt pour plus d'informations et vous rendre sur le forum de cairo-dock pour reporter l'erreur dans la section \"Version BZR\" "
			else
				echo "Some errors have been detected during the installation"
				egrep -i "( error| Erreur)" $1
				echo "Please keep a copy of the file 'log.txt' and report the bug on our forum (http://www.cairo-dock.org) on the section \"Version BZR\". Thanks ! "
			fi
			echo -e "$NORMAL"
			if [[ `ps aux | grep -e "[c]airo-dock -"` ]]; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Erreur à la compilation
Cairo-Dock: Compilation error
	=> http://www.cairo-dock.org" int32:10 string:terminal string:any string:none
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
			exit
		else
			echo -e "$VERT"
			echo "$LG_INSTALL_OK"
			echo -e "$NORMAL"
			if [[ `ps aux | grep -e "[c]airo-dock -"` ]]; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Mis à jour avec succès
Cairo-Dock: Updated successfully" int32:8 string:terminal string:any string:none
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
			exit
		fi
	fi
}

testping () {
	if [ "`ping -c1 $DOMAIN |grep received|cut -d, -f2`" != " 1 received" ]
	then
		echo -e "$ROUGE"
		if [ $LG -eq 0 ]; then
			echo "Le test de connexion vers Internet à échouée"
			echo "Réglez ce problème avant de poursuivre ce script"
		else
			echo "Internet Connexion Error"
			echo "It's required if you want to access to our server"
		fi
		echo -e "$NORMAL"
		sleep 5
		exit
	else
		echo -e "$VERT""\nInternet Connexion\t [ OK ]\n""$NORMAL"
	fi
}

check_new_script() {
	cp $SCRIPT $SCRIPT_SAVE #pour moi :)

	if [ $LG -eq 0 ]; then
		echo -e "$NORMAL""Test de la connexion Internet (Obligatoire)"
		testping
		echo "Vérification de la disponibilité d'un nouveau script"
		LG_UPDL="Une mise à jour a été téléchargée"
		LG_CLICKHERE="Cliquez sur Ok pour relancer le script."
		LG_SCRIPT="Vous possédez la dernière version du script de M@v"
	else
		echo -e "$NORMAL""Connexion Internet test (Required)"
		testping
		echo "It checks if a new script exists"
		LG_UPDL="An update has been downloaded"
		LG_CLICKHERE="Click here in order to relauch the script."
		LG_SCRIPT="You have the latest version of M@v'script"
	fi
	wget $HOST/$SCRIPT -q -O $SCRIPT_NEW
	diff $SCRIPT $SCRIPT_NEW >/dev/null
	if [ $? -eq 1 ]; then
		echo -e "$ROUGE"
		echo "$LG_UPDL"
		echo -e "$NORMAL"
		mv $SCRIPT_NEW $SCRIPT
		sudo chmod u+x $SCRIPT
		zenity --info --title=Cairo-Dock --text="$LG_CLICKHERE"
		./$SCRIPT
		exit
	else
		clear
		echo -e "$VERT""\n\t$LG_SCRIPT"
	fi
	echo -e "$NORMAL"
	rm $SCRIPT_NEW

}


#######################################################################
#	Autres fonctions
#######################################################################


detect_env_graph() 
{
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Détection de l'environnement graphique"
		## kde 3/4
		if [[ `ps aux | grep -e "[k]smserver"` ]]; then
		   if [[ `ps aux | grep -e "[k]ded4" ` ]]; then
		       ENV=2;
		       echo -e "$VERT""Votre environnement est KDE 4 \n"
		   else
		       ENV=2;
		       echo -e "$VERT""Votre environnement est KDE 3 \n"
		   fi
		## gnome
		elif [[ `ps aux | grep -e "[g]nome-settings-daemon" ` ]]; then
		   ENV=1;
		   if [ $DISTRIB = "gutsy" ]; then
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME_OLD
		   else
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME
		   fi
		   echo -e "$VERT""Votre environnement est GNOME \n"
		## xfce4
		elif [[ `ps aux | grep -e "[x]fce-mcs-manager"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Votre environnement est XFCE 4 \n"
		elif [[ `ps aux | grep -e "xfce"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Votre environnement est XFCE \n"
		else
		   echo -e "Type de session locale non détéctée, ou non supportée vous utilisez e17, fluxbox ???... \n"
		fi
	else
		echo -e "$BLEU""What's your DE (Desktop Environment)"
		## kde 3/4
		if [[ `ps aux | grep -e "[k]smserver"` ]]; then
		   if [[ `ps aux | grep -e "[k]ded4" ` ]]; then
		       ENV=2;
		       echo -e "$VERT""Your Desktop Environment is KDE 4 \n"
		   else
		       ENV=2;
		       echo -e "$VERT""Your Desktop Environment is KDE 3 \n"
		   fi
		## gnome
		elif [[ `ps aux | grep -e "[g]nome-settings-daemon" ` ]]; then
		   ENV=1;
		   if [ $DISTRIB = "gutsy" ]; then
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME_OLD
		   else
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME
		   fi
		   echo -e "$VERT""Your Desktop Environment is GNOME \n"
		## xfce4
		elif [[ `ps aux | grep -e "[x]fce-mcs-manager"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Your Desktop Environment is XFCE 4 \n"
		elif [[ `ps aux | grep -e "xfce"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Your Desktop Environment is XFCE \n"
		else
		   echo -e "You don't use a common Desktop Environment, don't hesitate to report any bugs ;) \n"
		fi
	fi

	return $ENV

} 

detect_distrib() {
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Détection de la distribution"
	else
		echo -e "$BLEU""What's your distribution"
	fi
	DISTRIB=$(grep -e DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2)

	if [ $LG -eq 0 ]; then
		if [ -n $DISTRIB ]; then
			echo -e "$VERT""Votre distribution est $(grep -e DISTRIB_DESCRIPTION /etc/lsb-release | cut -d= -f2) ($DISTRIB)"
			echo -e "$NORMAL"
		elif [ $(grep -c ^Debian /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Votre distribution est Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c ^"Linux Mint" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Votre distribution est Linux Mint"
			echo -e "$NORMAL"
		else 
			echo -e "$ROUGE""Impossible de déterminer la distribution\nATTENTION : Ce script est prévu pour Ubuntu et Debian\nWARNING : This script is provided for Ubuntu and Debian"
			echo -e "$NORMAL"
		fi
	else
		if [ -n $DISTRIB ]; then
			echo -e "$VERT""Your distribution is $(grep -e DISTRIB_DESCRIPTION /etc/lsb-release | cut -d= -f2) ($DISTRIB)"
			echo -e "$NORMAL"
		elif [ $(grep -c ^Debian /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Your distribution is Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c ^"Linux Mint" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Your distribution is Linux Mint"
			echo -e "$NORMAL"
		else 
			echo -e "$ROUGE""WARNING : This script is provided for Ubuntu and Debian"
			echo -e "$NORMAL"
		fi
	fi
}


check_dependancies() {
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Vérification des paquets nécessaires à la compilation" 
	else
		echo -e "$BLEU""Check up: Packages needed for the compilation" 
	fi

	dpkg -s sudo |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then #Debian
			if [ $LG -eq 0 ]; then
				echo -e "$ROUGE"" Le paquet 'sudo' n'est pas installé, veuillez l'installer avant de continuer.""$NORMAL"""
			else
				echo -e "$ROUGE"" 'sudo' package isn't installed. Please install it.""$NORMAL"""
			fi
			exit
		fi

	sudo -v # Pour que Nochka puisse aller regarder la tv en attendant la fin de la compilation ;-)

	sudo apt-get install -s cairo-dock | grep Inst > /dev/null	
	if [ $? -eq 1 ]; then  #CD est installé par paquet
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE"" Désinstallation du paquet 'Cairo-Dock' ""$NORMAL"""
		else
			echo -e "$ROUGE""Uninstallation of 'Cairo-Dock' package.""$NORMAL"""
		fi
		sudo apt-get purge -qq cairo-dock
	fi

	for tested in $NEEDED
	do
		dpkg -s $tested |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $tested isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $tested  >> $LOG_CAIRO_DOCK
		fi
	done

	if [ $ENV -eq 1 ]; then #Gnome
		dpkg -s $NEEDED_GNOME |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $NEEDED_GNOME isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $NEEDED_GNOME  >> $LOG_CAIRO_DOCK
		fi
	elif [ $ENV -eq 3 ]; then #XFCE
		dpkg -s $NEEDED_XFCE |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $NEEDED_XFCE isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $NEEDED_XFCE  >> $LOG_CAIRO_DOCK
		fi
	fi
	if [ $(grep -c ^Ubuntu /etc/issue) -eq 1 ]; then # pour ne pas avoir un message d'erreur sur les autres
		if [ $DISTRIB = 'karmic' ] || [ `lsb_release -rs | cut -d. -f1` -ge 10 ]; then #karmic ou nouveau
			dpkg -s $NEEDED_KARMIC |grep installed |grep "install ok" > /dev/null
			if [ $? -eq 1 ]; then
				echo -e "$ROUGE""This package $NEEDED_KARMIC isn't installed : Installation""$NORMAL"""
				sudo apt-get install -qq $NEEDED_KARMIC  >> $LOG_CAIRO_DOCK
			fi
		else
			dpkg -s $NEEDED_B_KARMIC |grep installed |grep "install ok" > /dev/null
			if [ $? -eq 1 ]; then
				echo -e "$ROUGE""This package $NEEDED_B_KARMIC isn't installed : Installation""$NORMAL"""
				sudo apt-get install -qq $NEEDED_B_KARMIC  >> $LOG_CAIRO_DOCK
			fi
		fi
	elif [ $(grep -c ^Debian /etc/issue) -eq 1 ]; then
		dpkg -s $NEEDED_KARMIC |grep installed |grep "install ok" > /dev/null
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $NEEDED_KARMIC isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $NEEDED_KARMIC  >> $LOG_CAIRO_DOCK
		fi
	else
		dpkg -s $NEEDED_KARMIC |grep installed |grep "install ok" > /dev/null
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $NEEDED_KARMIC isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $NEEDED_KARMIC  >> $LOG_CAIRO_DOCK
		fi
		dpkg -s $NEEDED_B_KARMIC |grep installed |grep "install ok" > /dev/null
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $NEEDED_B_KARMIC isn't installed : Installation""$NORMAL"""
			sudo apt-get install -qq $NEEDED_B_KARMIC  >> $LOG_CAIRO_DOCK
		fi
	fi

	if [ $LG -eq 0 ]; then
		echo -e "$VERT""Vérification [ OK ]"
	else
		echo -e "$VERT""Verification [ OK ]"
	fi
	echo -e "$NORMAL"""
	sleep 1
}


ppa_weekly() {
	if [ $(grep -c ^Debian /etc/issue) -eq 1 ]; then
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly-debian/ubuntu jaunty main ## Cairo-Dock-PPA-Weekly for Debian"
		su -s
		W_SUDO=""
	elif [ $(grep -c ^Ubuntu /etc/issue) -eq 1 ]; then
		LSB_RELEASE=`lsb_release -sc`
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly/ubuntu $LSB_RELEASE main ## Cairo-Dock-PPA-Weekly"
		sudo -v
		W_SUDO="sudo"
	elif [ $(grep -c ^"Linux Mint" /etc/issue) -eq 1 ]; then
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly-debian/ubuntu jaunty main ## Cairo-Dock-PPA-Weekly for Debian and the others forks"
		sudo -v
		W_SUDO="sudo"
	else
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE""Désolé, seuls Ubuntu et Debian sont supportés. En cas de problème, merci de nous contacter sur notre forum.""$NORMAL"""
		else
			echo -e "$ROUGE""Sorry but only Debian and Ubuntu are supported. If there is a problem, please contact us on our forum.""$NORMAL"""
		fi
		exit
	fi

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$BLEU""Désinstallation de la version BZR"
		else
			echo -e "$BLEU""Uninstallation of the BZR version"
		fi
		echo -e "$NORMAL"""
		uninstall
	fi

	echo -e "$VERT""PPA weekly - Repository"
	echo "Ajout du dépôt ppa weekly" >> $LOG_CAIRO_DOCK
	echo -e "$NORMAL"""

	echo -e "\nAjout du dépôt\n" >> $LOG_CAIRO_DOCK
	echo "$PPA" | $W_SUDO tee -a /etc/apt/sources.list  >> $LOG_CAIRO_DOCK
	echo -e "\nAjout de la clé\n" >> $LOG_CAIRO_DOCK
	$W_SUDO apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E80D6BF5 >> $LOG_CAIRO_DOCK
	echo -e "\nMise à jour de la apt list\n" >> $LOG_CAIRO_DOCK
	$W_SUDO apt-get update  >> $LOG_CAIRO_DOCK
	echo -e "\nInstallation\n" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation des paquets Cairo-Dock, version instable"
	echo -e "$NORMAL"""
	$W_SUDO apt-get install cairo-dock  >> $LOG_CAIRO_DOCK
	zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
	exit
}


about() {
	echo "Author : Mav & Matttbe"
	echo "Contact : mav@cairo-dock.org"
	exit
}

if [ "$1" = "smo_install" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	install
elif [ "$1" = "smo_update" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	update
elif [ "$1" = "-e" ]; then # possibilité d'ajouter des args
	ARGS=$2
	echo "$ARGS" > $DIR/.args
	if [ $(grep -c "enable" $DIR/.args) -eq 1 ]; then # s'il y a au-moins un enable
		CONFIGURE="$CONFIGURE $ARGS"
	else
		for arg in $ARGS
		do
			CONFIGURE="$CONFIGURE --enable-$arg"
		done
	fi
	rm -f $DIR/.args
fi

echo $LANG | grep -c ^fr > /dev/null
if [ $? -eq 0 ]; then 
	LG=0
	LG_CLOSE="Cliquez sur Ok pour fermer le terminal."
else
	LG=1
	LG_CLOSE="Click on Ok in order to close the terminal."
fi

if [ $DEBUG -ne 1 ]; then
	if [ `date +%Y%m%d` -gt 20100205 ];then
		check_new_script
	fi
fi

if [ $LG -eq 0 ]; then
	echo -e "$NORMAL""Script d'installation de la version BZR de Cairo-Dock (FR)\n"
	echo -e "Veuillez choisir l'option d'installation : \n"

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "\t1 --> Mettre à jour la version BZR installée"
		echo -e "\t2 --> Reinstaller la version BZR actuelle"
		echo -e "\t3 --> Désinstaller la version BZR"
		echo -e "\t4 --> Installer le ppa weekly au lieu de BZR "
		echo -e "\t5 --> A propos"

		echo -e "\nVotre choix : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				update
			;;

			"2")
				detect_distrib
				detect_env_graph
				check_dependancies
				reinstall
			;;

			"3")
				uninstall
				zenity --info --title=Cairo-Dock --text="Cairo-Dock a été désinstallé, veuillez lire le message dans le terminal"
				exit
			;;

			"4")
				ppa_weekly
			;;

			"5")
				about
			;;
		esac
	else
		echo -e "\t1 --> Installer la version BZR pour la première fois"
		echo -e "\t2 --> Installer le ppa weekly au lieu de BZR"
		echo -e "\t3 --> A propos"

		echo -e "\nVotre choix : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				install
			;;

			"2")
				ppa_weekly
			;;

			"3")
				about
			;;
		esac
	fi
else
		echo -e "$NORMAL""Installation script for BZR version of Cairo-Dock (EN)\n"
	echo -e "What do you want : \n"

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "\t1 --> Update Cairo-Dock to the latest BZR revision"
		echo -e "\t2 --> Reinstall the current version"
		echo -e "\t3 --> Uninstall the current version"
		echo -e "\t4 --> Install weekly ppa instead of BZR"
		echo -e "\t5 --> About this script"

		echo -e "\nYour choice : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				update
			;;

			"2")
				detect_distrib
				detect_env_graph
				check_dependancies
				reinstall
			;;

			"3")
				uninstall
				zenity --info --title=Cairo-Dock --text="Cairo-Dock has been uninstalled, please read the message into the terminal"
				exit
			;;

			"4")
				ppa_weekly
			;;

			"5")
				about
			;;
		esac
	else
		echo -e "\t1 --> Install the current version of Cairo-Dock from BZR server for the first time (Install)"
		echo -e "\t2 --> Install weekly ppa instead of BZR"
		echo -e "\t3 --> About this script"

		echo -e "\nYour choice : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				install
			;;

			"2")
				ppa_weekly
			;;

			"3")
				about
			;;
		esac
	fi
fi
