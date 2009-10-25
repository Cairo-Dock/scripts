#!/bin/bash

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m"
ROUGE="\\033[1;31m"

if ! test -d debian; then
	echo -e "$ROUGE""Le dossier debian n'existe pas""$NORMAL"
elif ! test -d ubuntu; then
	echo -e "$ROUGE""Le dossier ubuntu n'existe pas""$NORMAL"
fi

echo -e "$BLEU""Disposition à avoir pour lancer le script:""$NORMAL""
\t|-debian
\t|-----|-Incoming
\t|-----|-----|-cairo-dock
\t|-----|-----|-cairo-dock-plug-ins
\t|-ubuntu
\t|-----|-Incoming
\t|-----|-----|-cairo-dock
\t|-----|-----|-cairo-dock-plug-ins
\n* ""$ROUGE""Les paquets deb doivent avoir été téléchargés ! ""$NORMAL""
\n* ""$ROUGE""Les paquets plug-ins pour Ubuntu Hardy seront copiés automatiquement du dossier de Debian"
echo -e "$VERT""Continuer ? [O/n]""$NORMAL"
read continuer
if test "$continuer" = "n" -o  "$continuer" = "N"; then
	exit 0
fi

echo -e "$BLEU""\tCopie des fichiers pour Ubuntu Hardy\n""$NORMAL"
mv debian/Incoming/cairo-dock-plug-ins/cairo-dock-plug-ins*~hardy_*.deb ubuntu/Incoming/cairo-dock-plug-ins/

echo -e "$BLEU""\tDépot Debian\n""$NORMAL"
	cd debian/
	./debian.sh -p

echo -e "$BLEU""\tDépot Ubuntu\n""$NORMAL"
	cd ../ubuntu/
	./ubuntu.sh -p

echo -e "$VERT""Opération terminée""$NORMAL"
	cd ../
