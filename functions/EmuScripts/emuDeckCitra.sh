#!/bin/bash
#variables
Citra_emuName="Citra"
Citra_emuType="$emuDeckEmuTypeAppImage"
Citra_emuPath="$HOME/Applications/citra-qt.AppImage"
Citra_releaseURL=""
Citra_configFile="$HOME/.config/citra-emu/qt-config.ini"
Citra_configPath="$HOME/.config/citra-emu"
Citra_texturesPath="$HOME/.config/citra-emu/load/textures"
Citra_flatpakPath="$HOME/.var/app/org.citra_emu.citra"
Citra_flatpakconfigPath="$Citra_flatpakPath/config/citra-emu"
Citra_flatpakconfigFile="$Citra_flatpakconfigPath/qt-config.ini"
#cleanupOlderThings
Citra_finalize(){
 echo "NYI"
}

#Install
Citra_install(){
	setMSG "Installing $Citra_emuName"
	installEmuFP "${Citra_emuName}" "${Citra_emuPath}"
	curl -L https://github.com/citra-emu/citra-web/releases/download/2.0/citra-setup-linux > citra-setup-linux && chmod +x citra-setup-linux && ./citra-setup-linux --accept-licenses --confirm-command install
	rm citra-setup-linux
}

#ApplyInitialSettings
Citra_init(){
	setMSG "Initializing $Citra_emuName settings."
	#configEmuFP "${Citra_emuName}" "${Citra_emuPath}" "true"
	#Citra_migrate
	#Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	#SRM_createParsers
	#Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
	cp "$EMUDECKGIT/tools/launchers/citra.sh" "$toolsPath/launchers/citra.sh"
	chmod +x "$toolsPath/launchers/citra.sh"

  	createDesktopShortcut   "$HOME/.local/share/applications/Citra.desktop" \
							"Citra (AppImage/Flatpak)" \
							"${toolsPath}/launchers/citra.sh"  \
							"False"


}

#update
Citra_update(){
	setMSG "Updating $Citra_emuName settings."
	cd $HOME/.citra && ./maintenancetool update
	Citra_setupStorage
	Citra_setEmulationFolder
	Citra_setupSaves
	Citra_addSteamInputProfile
	Citra_flushEmulatorLauncher
}

#ConfigurePaths
Citra_setEmulationFolder(){
	setMSG "Setting $Citra_emuName Emulation Folder"

	mkdir -p "$Citra_configPath"
	rsync -avhp "$EMUDECKGIT/configs/org.citra_emu.citra/config/citra-emu/qt-config.ini" "$Citra_configPath/qt-config.ini" --backup --suffix=.bak
	gameDirOpt='Paths\\gamedirs\\3\\path='
	newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
	sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Citra_configFile"

	#Setup symlink for AES keys
	mkdir -p "${biosPath}/citra/"
	mkdir -p "$HOME/.local/share/citra-emu/sysdata"
	ln -sn "$HOME/.local/share/citra-emu/sysdata" "${biosPath}/citra/keys"

	if [ -d $Citra_flatpakPath ]; then 

		mkdir -p $Citra_flatpakconfigPath
		rsync -avhp "$EMUDECKGIT/configs/org.citra_emu.citra/config/citra-emu/qt-config.ini" "$Citra_flatpakconfigPath/qt-config.ini" --backup --suffix=.bak
		gameDirOpt='Paths\\gamedirs\\3\\path='
		newGameDirOpt='Paths\\gamedirs\\3\\path='"${romsPath}/n3ds"
		sed -i "/${gameDirOpt}/c\\${newGameDirOpt}" "$Citra_flatpakconfigFile"

		#Setup symlink for AES keys
		mkdir -p "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sysdata"
		mkdir -p "${biosPath}/citra-flatpak"
		ln -sn "$HOME/.var/app/org.citra_emu.citra/data/citra-emu/sysdata" "${biosPath}/citra-flatpak/keys"

	fi


}

#SetupSaves
Citra_setupSaves(){
	linkToSaveFolder citra saves "$HOME/.local/share/citra-emu/sdmc"
	linkToSaveFolder citra states "$HOME/.local/share/citra-emu/states"
}



#WipeSettings
Citra_wipe(){
	setMSG "Wiping $Citra_emuName config directory. (factory reset)"
	rm -rf "$HOME/.config/citra-emu"
}


#Uninstall
Citra_uninstall(){
	setMSG "Uninstalling $Citra_emuName."
	cd $HOME/.citra && ./maintenancetool purge
}

#setABXYstyle
Citra_setABXYstyle(){
		echo "NYI"
}

#Migrate
Citra_migrate(){
echo "Begin Citra Migration"
	emu="Citra"
	migrationFlag="$HOME/.config/EmuDeck/.${emu}MigrationCompleted"
	#check if we have a nomigrateflag for $emu
	if [ ! -f "$migrationFlag" ]; then
		#citra flatpak to appimage
		#From -- > to
		migrationTable=()
		migrationTable+=("$HOME/.var/app/org.citra_emu.citra/data/citra-emu" "$HOME/.local/share/citra-emu")
		migrationTable+=("$HOME/.var/app/org.citra_emu.citra/config/citra-emu" "$HOME/.config/citra-emu")

		# migrateAndLinkConfig "$emu" "$migrationTable"
	fi

	#move data from hidden folders out to these folders in case the user already put stuff here.
	origPath="$HOME/.var/app/org.citra_emu.citra/data/citra_emu/"

	Citra_setupStorage

	rsync -av "${origPath}citra/dump" "${storagePath}/citra/" && rm -rf "${origPath}citra/dump"
	rsync -av "${origPath}citra/load" "${storagePath}/citra/" && rm -rf "${origPath}citra/load"
	rsync -av "${origPath}citra/sdmc" "${storagePath}/citra/" && rm -rf "${origPath}citra/sdmc"
	rsync -av "${origPath}citra/nand" "${storagePath}/citra/" && rm -rf "${origPath}citra/nand"
	rsync -av "${origPath}citra/screenshots" "${storagePath}/citra/" && rm -rf "${origPath}citra/screenshots"
	rsync -av "${origPath}citra/tas" "${storagePath}/citra/" && rm -rf "${origPath}citra/tas"
}

#WideScreenOn
Citra_wideScreenOn(){
echo "NYI"
}

#WideScreenOff
Citra_wideScreenOff(){
echo "NYI"
}

#BezelOn
Citra_bezelOn(){
echo "NYI"
}

#BezelOff
Citra_bezelOff(){
echo "NYI"
}

#finalExec - Extra stuff
Citra_finalize(){
	echo "NYI"
}

Citra_IsInstalled(){
	if [ -e "$Citra_emuPath" ]; then
		echo "true"
	else
		isFpInstalled "citra_emu"
	fi
}

Citra_resetConfig(){
	Citra_init &>/dev/null && echo "true" || echo "false"
}

Citra_addSteamInputProfile(){
	addSteamInputCustomIcons
	#rsync -r "$EMUDECKGIT/configs/steam-input/citra_controller_config.vdf" "$HOME/.steam/steam/controller_base/templates/"
}

Citra_setResolution(){
	case $citraResolution in
		"720P") multiplier=3;;
		"1080P") multiplier=5;;
		"1440P") multiplier=6;;
		"4K") multiplier=9;;
		*) echo "Error"; return 1;;
	esac

	setConfig "resolution_factor" $multiplier "$Citra_configFile"
}

Citra_flushEmulatorLauncher(){


	flushEmulatorLaunchers "citra"

}