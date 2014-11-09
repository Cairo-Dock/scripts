#!/bin/bash

# Script for Git install for Cairo-Dock
#
# Copyright : (C) 2008-2009 by Yann SLADEK (SVN)
#                 2009-2014 by Matthieu BAERTS (BZR)
#                 2014 by Matthieu BAERTS (GIT)
# E-mail : mav@glx-dock.org, matttbe@glx-dock.org
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


## Changelog
# 01/11/14 :	matttbe : Switch to Git, removed old dependences, options, etc.

DEBUG=0 # Warning: do not forget to reset it to 0
DIR=$(pwd)

# CMake params:
CONFIGURE="-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug"
CONFIGURE_CORE="-Denable-desktop-manager=ON"
CONFIGURE_PG="-Denable-network-monitor=ON -Denable-doncky=ON -Denable-scooby-do=ON -Denable-disks=ON -Denable-global-menu=ON"

# Script
LOG_CAIRO_DOCK=$DIR/log.txt
SCRIPT="cairo-dock_git.sh"
SCRIPT_SAVE=".$SCRIPT.save"
SCRIPT_NEW=".$SCRIPT.new"
HOST="http://download.tuxfamily.org/glxdock/scripts/"
DOMAIN="glx-dock.org"

# Git
GIT_REPO_ORIGIN="Cairo-Dock"
GIT_REPO_HTTPS="https://github.com/"
GIT_REPO_SSH="git@github.com:"

# DIR
CAIRO_DOCK_CORE_DIR="cairo-dock-core"
CAIRO_DOCK_PLUG_INS_DIR="cairo-dock-plug-ins"
CAIRO_DOCK_PLUG_INS_EXTRAS_DIR="cairo-dock-plug-ins-extras"
CAIRO_DOCK_PLUG_INS_EXTRAS_USR="/usr/share/cairo-dock/plug-ins/Dbus/third-party"
CAIRO_DOCK_PLUG_INS_EXTRAS_HOME="$HOME/.config/cairo-dock/third-party"
CAIRO_DESKLET_DIR="cairo-desklet"
BUILD_DIR="build"

# Dependences
NEEDED_THIRD_PARTY="python valac ruby mono-gmcs libglib2.0-cil-dev libndesk-dbus1.0-cil-dev libndesk-dbus-glib1.0-cil-dev"
NEEDED="git build-essential pkg-config zenity gettext libcairo2-dev librsvg2-dev libdbus-glib-1-dev libxxf86vm-dev x11proto-xf86vidmode-dev libxrandr-dev libxcomposite-dev libxrender-dev libasound2-dev libxtst-dev libetpan-dev libexif-dev curl libglib2.0-dev cmake libcurl4-gnutls-dev libical-dev gdb libsensors4-dev libpulse-dev libxklavier-dev libdbusmenu-glib-dev libupower-glib-dev libzeitgeist-dev libgtk-3-dev libgl1-mesa-dev libglu1-mesa-dev libpango1.0-dev libdbusmenu-gtk3-dev libido3-0.1-dev libindicator3-dev libwebkitgtk-3.0-dev  libgnome-menu-3-dev libwayland-dev $NEEDED_THIRD_PARTY "
NEEDED_GNOME="gnome-session"
NEEDED_UNTIL_14_10="libvte-2.90-dev"
NEEDED_SINCE_15_04="libvte-2.91-dev"
CD_PACKAGES="cairo-dock cairo-dock-core cairo-dock-data cairo-dock-plug-ins cairo-dock-plug-ins-data cairo-dock-plug-ins-integration libgldi-dev libgldi3 cairo-dock-plug-ins-dbus-interface-python cairo-dock-plug-ins-dbus-interface-mono cairo-dock-plug-ins-dbus-interface-ruby cairo-dock-plug-ins-dbus-interface-vala"

ERROR=0

TRAP_ON='echo -e "\e]0;$BASH_COMMAND\007"' # Afficher la commande en cours dans le terminal
TRAP_OFF="trap DEBUG"
CORES=$(grep -c "^processor" /proc/cpuinfo)

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m"
ROUGE="\\033[1;31m"


#######################################################################
#	INSTALLATION
#######################################################################

install_cairo_dock() {

	rm -Rf $LOG_CAIRO_DOCK > /dev/null

	echo "Installation of Cairo-Dock (`date`)" >> $LOG_CAIRO_DOCK

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation : Cairo-Dock Core"

	install_cairo_dock_src >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR=1
		echo -e "$ROUGE""\tError"
		check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}

install_cairo_dock_src() {
	cd "$DIR/$CAIRO_DOCK_CORE_DIR"

	# Build DIR
	rm -rf $BUILD_DIR
	mkdir $BUILD_DIR
	cd $BUILD_DIR

	cmake .. $CONFIGURE $CONFIGURE_CORE && make clean && make -j $CORES

	if [ $? -ne 0 ]; then
		cd "$DIR"
		return 1
	fi

	sudo rm -rf /usr/include/cairo-dock/* /usr/lib/libgldi.so* /usr/share/cairo-dock/*
	sudo make install
	if [ $? -ne 0 ]; then
		cd "$DIR"
		return 1
	fi
	cd "$DIR"
}


install_cairo_dock_plugins() {

	echo -e "$BLEU""Installation : Plug-Ins"

	echo "Installation of plug-ins (`date`)" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK

	install_plugins >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR=1
		echo -e "$ROUGE""\tError"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}


install_plugins() {

	cd "$DIR/$CAIRO_DOCK_PLUG_INS_DIR"


	rm -rf $BUILD_DIR
	mkdir $BUILD_DIR
	cd $BUILD_DIR

	cmake .. $CONFIGURE $CONFIGURE_PG && make clean && make -j $CORES

	if [ $? -ne 0 ]; then
		cd "$DIR"
		return 1
	fi

	sudo rm -rf /usr/lib/cairo-dock/* /usr/share/cairo-dock/plug-ins/*
	sudo make install
	if [ $? -ne 0 ]; then
		cd "$DIR"
		return 1
	fi
	cd "$DIR"
}


install_cairo_dock_plugins_extras() {
	echo -e "$BLEU""Installation : Plug-ins Extras"

	cd "$DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_DIR"
	echo -e "\tCheck dependences"
	sh dependences_deb.sh >> $LOG_CAIRO_DOCK
	if [ $? -ne 0 ]; then
		ERROR=1
		echo -e "$ROUGE""\tError when installing dependences for 'plug-ins-extras', continue...""$NORMAL"
		# do not return, not a big deal
	fi

	echo "Installation of Plug-ins Extras (`date`)" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK

	./install_applet.sh
	if [ $? -ne 0 ]; then
		ERROR=1
		echo -e "$ROUGE""\tError when installing plug-ins extras""$NORMAL"
		cd "$DIR"
		return 1
	fi

	cd "$DIR"

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}


install_cairo_desklet() {

	echo "Installation de Cairo-Desklet" >> $LOG_CAIRO_DOCK

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation : Cairo-Desklet"

	install_desklet >> $LOG_CAIRO_DOCK 2>&1

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

install_desklet() {
	cd "$DIR/$CAIRO_DESKLET_DIR"

	rm -rf $BUILD_DIR
	mkdir $BUILD_DIR
	cd $BUILD_DIR
	cmake .. $CONFIGURE && make clean && make -j $CORES

	if [ $? -ne 0 ]; then
		cd "$DIR"
		return 1
	fi

	sudo rm -rf /usr/share/cairo-desklet
	sudo make install
	cd "$DIR"
}



install(){
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Téléchargement des données. Cette opération peut prendre quelques minutes"
		LG_SSH="Voulez-vous utiliser SSH pour télécharger les dépôts Git ?\nCeci est conseillé si vous désirez contribuer au développement mais vous devez avoir un compte Github sur lequel vous avez envoyé la clé public SSH de ce PC.\nSi vous ne comprenez pas ce message ou que vous désirez uniquement compiler la version de développement du dock, répondez N à cette question.\nVotre réponse [y/N] : "
		LG_FORK="Voulez-vous utiliser le dépôt officiel (Y - choix par défaut) ou un fork (n)? "
		LG_DL_BG="Téléchargement de"
		LG_DL_END="Données téléchargées. L'installation va débuter\nCette opération peut prendre plusieurs minutes et ralentir votre système"
		LG_DL_ERROR="Impossible de se connecter au serveur de Launchpad, veuillez vérifier votre connexion internet ou retenter plus tard"
	else
		echo -e "$BLEU""The download will begin. Please wait ;)"
		LG_SSH="Do you want to use SSH to download all Git repositories?\nThis is adviced if you want to contribute to the development of this project but you need a Github account which contains your SSH public key of this computer.\nIf you do not understand this message or if you just want to compile the development version of the dock, answer N to this question.\nYour answer [y/N]: "
		LG_FORK="Do you want to use the official repo (Y - default choise) or a 'fork' (n)? "
		LG_DL_BG="Download of"
		LG_DL_END="Sources files downloaded. The installation will begin\nThis compilation can take some time and slow down your system"
		LG_DL_ERROR="It seems that there is some problems. Please check your Internet connexion or retry later!"
	fi

	echo -e "$NORMAL"

	if [ -f $HOME/.ssh/id_rsa.pub -o -f $HOME/.ssh/id_dsa.pub ]; then
		echo -e "$LG_SSH"
		read DL_SSH
		[ "$DL_SSH" = "y" -o "$DL_SSH" = "Y" ] && GIT_REPO=$GIT_REPO_SSH || GIT_REPO=$GIT_REPO_HTTPS
	fi

	read -p "$LG_FORK" DL_FORK
	[ "$DL_FORK" = "n" -o "$DL_FORK" = "N" ] && read -p "User/Organisation name of your fork repo (e.g. Cairo-Dock)" FORK_ORIGIN || FORK_ORIGIN=$GIT_REPO_ORIGIN
	GIT_REPO="${GIT_REPO}${FORK_ORIGIN}"

#	read -p "$LG_COLOURS" ENABLE_COLOURS
#	[ "$ENABLE_COLOURS" != "n" -a "$ENABLE_COLOURS" != "N" ] && git config --global color.ui auto

	if [ ! -d "$DIR/$CAIRO_DOCK_CORE_DIR" ]; then
		echo -e "$BLEU""$LG_DL_BG Cairo-Dock Core"
		echo -e "$NORMAL"
		git clone "${GIT_REPO}/${CAIRO_DOCK_CORE_DIR}"
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS ##

	if [ ! -d "$DIR/$CAIRO_DOCK_PLUG_INS_DIR" ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins"
		echo -e "$NORMAL"
		git clone "${GIT_REPO}/${CAIRO_DOCK_PLUG_INS_DIR}"
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS EXTRAS ##

	if [ ! -d "$DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_DIR" ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins Extras"
		echo -e "$NORMAL"
		git clone "${GIT_REPO}/${CAIRO_DOCK_PLUG_INS_EXTRAS_DIR}"
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		fi
	fi

	echo -e "$NORMAL" ## CAIRO-DESKLET ##

	if [ ! -d "$DIR/$CAIRO_DESKLET_DIR" ]; then
		echo -e "$BLEU""$LG_DL_BG Desklets"
		echo -e "$NORMAL"
		git clone "${GIT_REPO}/${CAIRO_DESKLET_DIR}"
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		fi
	fi

	echo -e "$NORMAL"
	echo -e "$BLEU""$LG_DL_END"
	echo -e "$NORMAL"

	sleep 5

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	install_cairo_desklet

	check $LOG_CAIRO_DOCK "CD"
}


reinstall(){
	FULL_COMPILE=1

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	install_cairo_desklet

	check $LOG_CAIRO_DOCK "CD"
}



#######################################################################
#	UNINSTALL
#######################################################################


uninstall() {
	echo "Uninstallation of Cairo-Dock and its plug-ins"

	# Core
	cd "$DIR/$CAIRO_DOCK_CORE_DIR/$BUILD_DIR"
	sudo make uninstall > $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	# Plug-ins
	cd "$DIR/$CAIRO_DOCK_PLUG_INS_DIR/$BUILD_DIR"
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	# Extras
	sudo rm -r $CAIRO_DOCK_PLUG_INS_EXTRAS_USR

	# Desklet
	cd "$DIR/$CAIRO_DESKLET_DIR/$BUILD_DIR"
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	echo "Uninstallation finished"
	echo ""
	echo "Note that your Cairo-Dock' settings are still available in ~/.config/cairo-dock"
}



#######################################################################
#	UPDATE
#######################################################################

# return 1 in case of error
update_git_repo(){
	# another branch?
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	if [ "$BRANCH" != "master" ]; then
		echo "You're not on the master branch (but on $BRANCH)!"
		read -p "Do you want to stash your uncommited changes (if needed), switch to the master branch and continue the update (Y) or exit (n)? [Y/n] " CONTINUE
		[ "$CONTINUE" = "n" -o "$CONTINUE" = "N" ] && exit 1
		[ $(git status -s --untracked-files=no | wc -l) -gt 0 ] && git stash
		git checkout master || exit $?
	fi

	# has some changes?
	if [ $(git status -s --untracked-files=no | wc -l) -gt 0 ]; then
		echo "Some uncommited changes have been detected."
		read -p "Do you want to stash them (s), to discard them (d), continue (c) or exit (E)? [s/d/c/E] " CONTINUE
		case "$CONTINUE" in
			[sS])
				git stash
				;;
			[dD])
				echo "Reverting these changes"
				git --no-pager diff
				git checkout -- .
				;;
			[cC])
				echo "Here is your current changes:"
				git --no-pager status -s
				;;
			*)
				exit 0
				;;
		esac
	fi

	# new rev?
	REV=$(git rev-parse HEAD)
	git pull -q >> $LOG_CAIRO_DOCK || exit $?
	REV_NEW=$(git rev-parse HEAD)
	echo "Update: $REV -> $REV_NEW" >> $LOG_CAIRO_DOCK
	if [ "$REV" != "$REV_NEW" ]; then
		git --no-pager shortlog $REV..
		return 1
	fi
	return 0
}

update(){
	UPDATE=0
	if [ $LG -eq 0 ]; then
		LG_SEARCH_FOR="Recherche des mises à jour pour"
		LG_UP_FOUND="Une mise à jour a été détectée pour"
		LG_NO_UP="Pas de mise à jour disponible"
	else
		LG_SEARCH_FOR="Check if there is an update for"
		LG_UP_FOUND="An update has been detected for"
		LG_NO_UP="No update available"
	fi

	echo -e "$BLEU""$LG_SEARCH_FOR Cairo-Dock"
	cd "$DIR/$CAIRO_DOCK_CORE_DIR"
	update_git_repo
	UPDATE_CAIRO_DOCK=$?
	cd "$DIR"

	if [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		echo -e "$VERT""\n$LG_UP_FOUND Cairo-Dock"
		sleep 1
		install_cairo_dock
		UPDATE=1
	fi

	## PLUG-INS ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Plug-ins"
	cd "$DIR/$CAIRO_DOCK_PLUG_INS_DIR"
	update_git_repo
	UPDATE_PLUG_INS=$?
	cd "$DIR"

	if [ $UPDATE_PLUG_INS -eq 1 ]; then
		echo -e "$VERT""\n$LG_UP_FOUND Plug-Ins"
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

	## PLUG-INS EXTRAS ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Plug-ins Extras"
	cd "$DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_DIR"
	update_git_repo
	UPDATE_PLUG_INS_EXTRAS=$?
	cd "$DIR"

	if [ $UPDATE_PLUG_INS_EXTRAS -eq 1 ]; then
		echo -e "$VERT""\n$LG_UP_FOUND Plug-Ins Extras"
		install_cairo_dock_plugins_extras
		UPDATE=1
	fi

	## CAIRO-DESKLET ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Desklets"
	cd "$DIR/$CAIRO_DESKLET_DIR"
	update_git_repo
	UPDATE_DESKLET=$?
	cd "$DIR"

	if [ $UPDATE_DESKLET -eq 1 ]; then
		echo -e "$VERT""\n$LG_UP_FOUND Desklet"
		install_cairo_desklet
		UPDATE=1
	elif [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$VERT""Recompilation suite à la mise à jour de l'API Cairo-Dock"
		else
			echo -e "$VERT""Recompilation due to some changes of Cairo-Dock API"
		fi
		install_cairo_desklet
	fi

	## CHECK ##

	echo -e "$NORMAL"

	if [ $UPDATE -eq 1 ]; then
		check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$BLEU""$LG_NO_UP"
		echo -e "$NORMAL"
		if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
			dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: $LG_NO_UP" int32:8 string:"class=$COLORTERM"
		else
			zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
		fi
	fi
}


#######################################################################
#	Verification
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
				egrep -i "( error| Erreur)" $1 | grep -v error.svg
				echo -e "Veuillez consulter le fichier log.txt pour plus d'informations et vous rendre sur le forum de cairo-dock pour reporter l'erreur dans la section \"Version GIT\". Merci !\n"
			else
				echo "Some errors have been detected during the installation"
				egrep -i "( error| Erreur)" $1 | grep -v error.svg
				echo -e "Please keep a copy of the file 'log.txt' and report the bug on our forum (http://www.glx-dock.org) on the section \"Version GIT\". Thank you!\n"
			fi
			check_version
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Compilation error
Cairo-Dock: Erreur à la compilation
	Please report this bug !=> http://www.glx-dock.org" int32:0 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		else
			echo -e "$VERT"
			echo "$LG_INSTALL_OK"
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Successfully Updated
Cairo-Dock: Mis à jour avec succès" int32:8 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
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
		read
		exit
	else
		echo -e "$VERT""\nInternet Connexion\t [ OK ]\n""$NORMAL"
	fi
}

check_new_script() {
	cp $SCRIPT $SCRIPT_SAVE # for me :)

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
#	Misc.
#######################################################################

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
		elif [ $(grep -c "^Debian" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Votre distribution est Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
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
		elif [ $(grep -c "^Debian" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Your distribution is Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
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

	dpkg -s sudo |grep installed |grep "install ok" > /dev/null 2>&1
		if [ $? -eq 1 ]; then #Debian
			if [ $LG -eq 0 ]; then
				echo -e "$ROUGE"" Le paquet 'sudo' n'est pas installé, veuillez l'installer avant de continuer.""$NORMAL"""
			else
				echo -e "$ROUGE"" 'sudo' package isn't installed. Please install it.""$NORMAL"""
			fi
			read
			exit
		fi

	sudo -v # Pour que Nochka puisse aller regarder la tv en attendant la fin de la compilation ;-)

	if [ $(grep -c "^Ubuntu" /etc/issue) -eq 1 ]; then # pour ne pas avoir un message d'erreur sur les autres
		# VERSIONS
		if [ `lsb_release -rs | cut -d. -f1` -ge 15 ]; then #vivid or newer
			NEEDED="$NEEDED $NEEDED_SINCE_15_04 "
		else
			NEEDED="$NEEDED $NEEDED_UNTIL_14_10 "
		fi

		# ENVIRONMENTS: gnome-session is now needed for the session
		if test -n "$GNOME_DESKTOP_SESSION_ID" -o `ps aux | grep -c "[g]nome-settings-daemon"` -gt 0; then #Gnome
			NEEDED="$NEEDED $NEEDED_GNOME "
		fi
	else # on test tout...
		NEEDED="$NEEDED $NEEDED_SINCE_15_04 $NEEDED_UNTIL_14_10"
	fi

	PKG_AVAILABLE=""
	PKG_OK=""

	for tested in $NEEDED
	do
		dpkg -s $tested |grep installed |grep "install ok" > /dev/null 2>&1
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $tested isn't installed : Added to the list""$NORMAL"""
			PKG_AVAILABLE="$PKG_AVAILABLE $tested"
		fi
	done

	for testPkg in $PKG_AVAILABLE; do
		sudo apt-get install -s $testPkg > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			PKG_OK="$PKG_OK $testPkg"
		else
			echo -e "$ROUGE""This package $testPkg isn't available""$NORMAL"""
		fi
	done

	if [ "$PKG_OK" != "" ]; then
		echo -e "$ROUGE""Installing these packages: $PKG_OK""$NORMAL"""
		sudo apt-get install -y --force-yes -m -q $PKG_OK
	fi

	# check CD
	DPKG_SELECTIONS=`dpkg --get-selections`
	for cd_package in $CD_PACKAGES; do
		if [ `echo "$DPKG_SELECTIONS" | grep "$cd_package" | grep -c install` -ge 1 ]; then  #CD est installé par paquet
			CD_PACKAGES_RM="$CD_PACKAGES_RM $cd_package"
		fi
	done
	if test -n "$CD_PACKAGES_RM"; then
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE"" Désinstallation des paquets '$CD_PACKAGES_RM' ""$NORMAL"""
		else
			echo -e "$ROUGE""Uninstallation of these packages: '$CD_PACKAGES_RM'.""$NORMAL"""
		fi
		sudo apt-get purge -q $CD_PACKAGES_RM
		sudo apt-get autoremove --purge -q
	fi

	echo -e "$VERT""Verification [ OK ]"
	echo -e "$NORMAL"""
	sleep 1
}


ppa_weekly() {
	if [ $(grep -c "^Ubuntu" /etc/issue) -eq 1 ]; then
		LSB_RELEASE=`lsb_release -sc`
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly/ubuntu $LSB_RELEASE main ## Cairo-Dock-PPA-Weekly"
		sudo -v
		W_SUDO="sudo"
	elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly-debian/ubuntu jaunty main ## Cairo-Dock-PPA-Weekly for Debian and the others forks"
		sudo -v
		W_SUDO="sudo"
	else
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE""Désolé, seuls Ubuntu est supportés. En cas de problème, merci de nous contacter sur notre forum.""$NORMAL"""
		else
			echo -e "$ROUGE""Sorry but only Ubuntu is supported. If there is a problem, please contact us on our forum.""$NORMAL"""
		fi
		read
		exit
	fi

	if [ -d "$DIR/$CAIRO_DOCK_CORE_DIR" ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$BLEU""Désinstallation de la version GIT"
		else
			echo -e "$BLEU""Uninstallation of the GIT version"
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
}

menu_update() {
	case $1 in

		"1")
			detect_distrib
			check_dependancies
			update
		;;

		"2")
			detect_distrib
			check_dependancies
			reinstall
		;;

		"3")
			uninstall
			zenity --info --title=Cairo-Dock --text="$2"
			exit
		;;

		"4")
			ppa_weekly
		;;

		"5")
			check_version
		;;

		"6")
			about
		;;
	esac
}

menu_init() {
	case $1 in

		"1")
			detect_distrib
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
}

menu_display() {
	if [ $LG -eq 0 ]; then
		echo -e "$NORMAL""Script d'installation de la version GIT de Cairo-Dock (FR)\n"
		echo -e "Veuillez choisir l'option d'installation : \n"

		if [ -d "$DIR/$CAIRO_DOCK_CORE_DIR" ]; then
			echo -e "\t1 --> Mettre à jour la version GIT installée"
			echo -e "\t2 --> Reinstaller la version GIT actuelle"
			echo -e "\t3 --> Désinstaller la version GIT"
			echo -e "\t4 --> Installer le ppa weekly au lieu de GIT "
			echo -e "\t5 --> Afficher les actuelles numéros de révision."
			echo -e "\t6 --> A propos"

			echo -e "\nVotre choix : "
			read answer_menu
			menu_update $answer_menu "Cairo-Dock a été désinstallé, veuillez lire le message dans le terminal"
		else
			echo -e "\t1 --> Installer la version GIT pour la première fois"
			echo -e "\t2 --> Installer le ppa weekly au lieu de GIT"
			echo -e "\t3 --> A propos"

			echo -e "\nVotre choix : "
			read answer_menu
			menu_init $answer_menu
		fi
	else
		echo -e "$NORMAL""Installation script for GIT version of Cairo-Dock (EN)\n"
		echo -e "What do you want : \n"

		if [ -d "$DIR/$CAIRO_DOCK_CORE_DIR" ]; then
			echo -e "\t1 --> Update Cairo-Dock to the latest GIT revision"
			echo -e "\t2 --> Reinstall the current version"
			echo -e "\t3 --> Uninstall the current version"
			echo -e "\t4 --> Install weekly ppa instead of GIT"
			echo -e "\t5 --> Display the current installed revision"
			echo -e "\t6 --> About this script"

			echo -e "\nYour choice : "
			read answer_menu
			menu_update $answer_menu "Cairo-Dock has been uninstalled, please read messages in your terminal"
		else
			echo -e "\t1 --> Install the current version of Cairo-Dock from GIT server for the first time (Install)"
			echo -e "\t2 --> Install weekly ppa instead of GIT"
			echo -e "\t3 --> About this script"

			echo -e "\nYour choice : "
			read answer_menu
			menu_init $answer_menu
		fi
	fi
}

about() {
	echo -e "Author : Mav (2008-2009)\n\t matttbe (2009-2014)"
	echo -e "Contact : mav@glx-dock.org\n\t matttbe@glx-dock.org"
}

check_version() {
	echo -e "Cairo-Dock Core: $(git --git-dir=$CAIRO_DOCK_CORE_DIR/.git show --oneline -s)"
	echo -e "Cairo-Dock Plug-ins: $(git --git-dir=$CAIRO_DOCK_PLUG_INS_DIR/.git show --oneline -s)"
	echo -e "Cairo-Dock Plug-ins Extras: $(git --git-dir=$CAIRO_DOCK_PLUG_INS_EXTRAS_DIR/.git show --oneline -s)"
	echo -e "Cairo-Desklet: $(git --git-dir=$CAIRO_DESKLET_DIR/.git show --oneline -s)"
}

echo $LANG | grep -c "^fr" > /dev/null
if [ $? -eq 0 ]; then
	export LG=0
	LG_CLOSE="Cliquez sur Ok pour fermer le terminal."
else
	export LG=1
	LG_CLOSE="Click on Ok in order to close the terminal."
fi

if [ $DEBUG -ne 1 ]; then
	# if [ `date +%Y%m%d` -gt 20100220 ];then
		check_new_script
	# fi
fi

while getopts "iIuURe:N" flag
do
	#echo " option $flag $OPTIND $OPTARG"
	case "$flag" in
	[iI])
		detect_distrib
		check_dependancies
		install
		;;
	[uU])
		detect_distrib
		check_dependancies
		update
		;;
	R)
		detect_distrib
		check_dependancies
		reinstall
		;;
	e)
		ARGS=$OPTARG
		if [ $(echo "$ARGS" | grep -c "-D") -gt 1 ]; then # at least one enable
			CONFIGURE_PG="$CONFIGURE_PG $ARGS"
		else
			for arg in $ARGS
			do
				CONFIGURE_PG="$CONFIGURE_PG -Denable-${arg}=ON"
			done
		fi
		;;
	N)
		EXIT=1
		menu_display
		;;
	*)
		menu_display
		;;
	esac
done

[ "$1" = "" ] && menu_display

[ "$1" = "--no-exit" -o "$EXIT" = "1" ] && read
