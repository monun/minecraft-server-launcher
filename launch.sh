#!/bin/bash

########################## Configurations ##########################

# Server directory name
NAME="server"
# Server type (local path or type[vanilla, spigot, paper]-version[1.xx.x, unspecified]-build[latest, unspecified, xx])
SERVER="paper-1.19-unspecified"
# Server memory (GB)
MEMORY=8
# jdwp port, Enable debug mode when 0 or higher (5005)
DEBUG_PORT=-1
# When the server shuts down, use tar to back up.
BACKUP=false
# The server will always restart.
RESTART=false
# Preinstallation plugins (url)
PLUGINS=(
  # 'https://github.com/monun/auto-reloader/releases/latest/download/AutoReloader.jar'
)

####################################################################

# Check wget
! type -p wget >/dev/null && echo "wget not found" && exit

# Check jq
! type -p jq >/dev/null && echo "jq not found" && exit

# Check java
! type -p java >/dev/null && echo "java not found" && exit

# Create server directory and change
mkdir -p "$NAME"
cd "$NAME" || exit

# Check local path
if [[ -f $SERVER ]]; then
  JAR=$SERVER
# Setup server
elif [[ -f ../setup.sh ]]; then
  JAR=$(../setup.sh "$SERVER" | tail)
else
  JAR=$(curl -s "https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/setup.sh" | bash -s -- "$SERVER" | tail)
fi

# Exit if jar not found
[[ ! -f $JAR ]] && echo "Jar not found for $SERVER - $JAR" && exit

# Download plugins (Only if it's not vanilla)
if [[ $SERVER != vanilla* ]]; then
  mkdir -p "./plugins"
  for i in "${PLUGINS[@]}"; do
    wget -q -c --content-disposition -P "./plugins" -N "$i"
  done
fi

# Download start script
if [[ -f ../start.sh ]]; then
  cp ../start.sh .
else
  wget -q -c --content-disposition -P . -N "https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/start.sh" >/dev/null
fi

# Export variables for start.sh
export JAR
export MEMORY
export DEBUG_PORT
export BACKUP
export RESTART

# Run server
chmod +x ./start.sh
./start.sh launch
