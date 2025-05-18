#!/bin/bash
set -e

# Update VRising dedicated server using SteamCMD
if [ ! -f "$HOME/server/VRisingServer.exe" ]; then
	./steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$HOME/server" +login anonymous +app_update 1829350 validate +quit
else
	echo "VRisingServer.exe already exists, skipping SteamCMD update."
fi

# Checks if log file exists, if not creates it
current_date=$(date +"%Y%m%d-%H%M")
logfile="$current_date-VRisingServer.log"
if ! [ -f "$HOME/persistentdata/$logfile" ]; then
	echo "Creating $HOME/persistentdata/$logfile"
	touch "$HOME/persistentdata/$logfile"
fi

echo " "
if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "$HOME/server/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "$HOME/server/${unsupported_file}" "$HOME/server/${unsupported_file}.bak"
	fi
fi

echo " "

unsupported_file2="VRisingServer_Data/Plugins/x86_64/BacktraceCrashpadWindows.dll"
echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file2} exists"
if [ -f "$HOME/server/${unsupported_file2}" ]; then
	echo "Changing ${unsupported_file2} as attempt to fix issues..."
	mv "$HOME/server/${unsupported_file2}" "$HOME/server/${unsupported_file2}.bak"
fi


echo " "
mkdir "$HOME/persistentdata/Settings" 2>/dev/null
if [ ! -f "$HOME/persistentdata/Settings/ServerGameSettings.json" ]; then
	echo "$HOME/persistentdata/Settings/ServerGameSettings.json not found. Copying default file."
	cp "$HOME/server/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$HOME/persistentdata/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
	echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
	cp "$HOME/server/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$HOME/persistentdata/Settings/" 2>&1
fi

if [ ! -d $HOME/.wine/drive_c/windows ]; then
	echo "---Setting up WINE---"
    cd ${SERVER_DIR}
    winecfg
    sleep 15
else
	echo "---WINE properly set up---"
fi

# export WINEDLLOVERRIDES="winhttp=n,b"

wineboot --update
Xvfb :1 -screen 0 1024x768x16 &
echo "Launching wine64 V Rising"
echo " "
ps aux | grep Xvfb
echo " "
# Run the server via Wine
export DISPLAY=:1
wine64 "$HOME/server/VRisingServer.exe" -persistentDataPath "$HOME/persistentdata" -logFile "$HOME/persistentdata/$logfile"
