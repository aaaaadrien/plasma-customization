#!/bin/bash

# Tester si root
if [[ $(id -u) -eq "0" ]]
then
	echo -e "\033[31mATTENTION\033[0m Si vous lancez ce script en root, cela personnalisera la session KDE de root !"
	echo "Poursuite du script dans 10 secondes..."
	sleep 10
fi

echo "Configuration générale de KDE"
echo " - Suramplification"
kwriteconfig6 --file plasmaparc --group General --key RaiseMaximumVolume true

echo " - Modification du format de la date et heure"
read -r containment applet < <(
  awk '
    /^\[Containments\]\[[0-9]+\]$/ {
      containment = $0
      sub(/^\[Containments\]\[/, "", containment)
      sub(/\]$/, "", containment)
    }

    /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ {
      applet = $0
      sub(/^.*\[Applets\]\[/, "", applet)
      sub(/\]$/, "", applet)
      in_applet = 1
      next
    }

    /^\[/ { in_applet = 0 }

    in_applet && /^plugin=org\.kde\.plasma\.digitalclock$/ {
      print containment, applet
      exit
    }
  ' ~/.config/plasma-org.kde.plasma.desktop-appletsrc
)

if [[ -n "$containment" && -n "$applet" ]]
then
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
  --group Containments --group "$containment" \
  --group Applets --group "$applet" \
  --group Configuration --group Appearance \
  --key dateFormat custom

kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
  --group Containments --group "$containment" \
  --group Applets --group "$applet" \
  --group Configuration --group Appearance \
  --key customDateFormat "ddd d MMM yyyy"

kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
  --group Containments --group "$containment" \
  --group Applets --group "$applet" \
  --group Configuration --group Appearance \
  --key showSeconds Always

kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
  --group Containments --group "$containment" \
  --group Applets --group "$applet" \
  --group Configuration --group Appearance \
  --key use24hFormat 0
fi

#echo " - Localisation du pointeur via CTRL"

#echo " - Paramétrage Touch Pad"
#gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing true
#gsettings set org.gnome.desktop.peripherals.touchpad click-method "areas"

echo " - Désactivation des sons système"
kwriteconfig6 --file kdeglobals --group Sounds --key Enable false

#echo " - Timeout des applications en attente de réponse à 60s"

echo " - Activation du mode nuit"
kwriteconfig6 --file kwinrc --group NightColor --key Active true
qdbus6 org.kde.KWin /ColorCorrect org.kde.kwin.ColorCorrect.reconfigure 2>/dev/null

echo " - Epuration de la corbeille"
kwriteconfig6 --file ktrashrc --group "$HOME/.local/share/Trash" --key Days 30
kwriteconfig6 --file ktrashrc --group "$HOME/.local/share/Trash" --key LimitReachedAction 1
kwriteconfig6 --file ktrashrc --group "$HOME/.local/share/Trash" --key Percent 10
kwriteconfig6 --file ktrashrc --group "$HOME/.local/share/Trash" --key UseSizeLimit true
kwriteconfig6 --file ktrashrc --group "$HOME/.local/share/Trash" --key UseTimeLimit true

echo "Confidentialité de KDE"
echo " - Désactivation de l'envoi des rapports"
kwriteconfig6 --file PlasmaUserFeedback --group Global --key FeedbackLevel 0

echo "Personnalisation Thèmes"
echo " - Application du thème sombre KDE"
plasma-apply-lookandfeel -a org.kde.breezedark.desktop
echo " - Application du thème sombre GNOME"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "Configuration Dolphin"
echo " - Afficher la barre de menu"
kwriteconfig6 --file dolphinrc --group MainWindow --key MenuBar enabled

echo " - Dolphin vide à l'ouverture"
kwriteconfig6 --file dolphinrc --group General --key RememberOpenedTabs false

#echo " - Vue liste et activation du mode tree"
#gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
#gsettings set org.gnome.nautilus.list-view use-tree-view true
#gsettings set org.gnome.nautilus.list-view default-zoom-level = 'small'

echo " - Désactivation de l ouverture du dossier lorsqu un élément est glissé dedans"
kwriteconfig6 --file dolphinrc --group General --key AutoExpandFolders false

echo " - Navigation dans les ZIP"
kwriteconfig6 --file dolphinrc --group General --key BrowseThroughArchives true

echo " - Activation du double clic"
kwriteconfig6 --file kdeglobals --group KDE --key SingleClick false

#echo " - Modification de l ordre de tri"
#gsettings set org.gtk.Settings.FileChooser sort-directories-first true
#gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true

echo "Configuration de Discover"
echo " - Désactivation du téléchargement automatique des mises à jour"
kwriteconfig6 --file PlasmaDiscoverUpdates --group Global --key UseUnattendedUpdates false
echo " - Notifs journalières"
kwriteconfig6 --file PlasmaDiscoverUpdates --group Global --key RequiredNotificationInterval 86400

echo " - MàJ au reboot"
kwriteconfig6 --file discoverrc --group Software --key UseOfflineUpdates true

#echo " - Autorisation de la mise à niveau vers des versions BETA"
#gsettings set org.gnome.software show-upgrade-prerelease false

# A POURSUIVRE
#echo "Configuration de GNOME Text Editor"
#gsettings set org.gnome.TextEditor highlight-current-line false
#gsettings set org.gnome.TextEditor restore-session false
#gsettings set org.gnome.TextEditor show-line-numbers true

#echo "Configuration de GNOME Web"
#gsettings set org.gnome.Epiphany ask-for-default false
#gsettings set org.gnome.Epiphany homepage-url 'about:blank'
#gsettings set org.gnome.Epiphany start-in-incognito-mode true

#echo "Configuration de Ptyxis"
#gsettings set org.gnome.Ptyxis use-system-font false
#gsettings set org.gnome.Ptyxis font-name 'Monospace 14'
#gsettings set org.gnome.Ptyxis restore-session false

#echo "Application des fonts Red Hat"
#if rpm -q redhat-mono-fonts &> /dev/null
#then
#	gsettings set org.gnome.Ptyxis font-name 'Red Hat Mono Regular 14'
#fi

#if rpm -q redhat-text-fonts &> /dev/null
#then
#	gsettings set org.gnome.desktop.interface font-name 'Red Hat Text Regular 11'
#	gsettings set org.gnome.desktop.interface monospace-font-name 'Red Hat Mono Regular 10'
#fi


echo "Personnalisation terminée, reload de KDE Plasma"
systemctl restart --user plasma-plasmashell.service
