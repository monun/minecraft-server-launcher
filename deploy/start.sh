#!/bin/bash

# Create '.start' file when executing this script through the restart command on the server
if [[ $1 != "launch" ]]; then
  touch .start
  exit
fi

while :; do
  rm -f ".start"
  
  JVM_TYPE=""
  
  # outputs to stderr by default. route to stdout
  JAVA_PROPS=$(java -XshowSettings:properties -version 2>&1)
  
  # If current showSettings properties contains Hotspot string:
  case "$JAVA_PROPS" in
    *"HotSpot"*|*"Hotspot"*) JVM_TYPE="hotspot";;
    *"OpenJ9"*) JVM_TYPE="openj9";;
    
    # Added just for backwards compatibility with IBM J9 (up to Java 1.7)
    # Just in case.
    *"J9"*) JVM_TYPE="openj9";;
  esac
  
  echo "JAR=$JAR"
  echo "MEMORY=$MEMORY"
  echo "BACKUP=$BACKUP"
  echo "RESTART=$RESTART"
  echo "PLAYERS=$PLAYERS"
  echo "PLUGINS=$PLUGINS"
  echo "WORLDS=$WORLDS"
  echo "PORT=$PORT"
  echo "DEBUG_PORT=$DEBUG_PORT"
  echo "JVM_TYPE=$JVM_TYPE"

  # Common JVM Arguments
  jvm_arguments=(
    "-Xmx${MEMORY}G"
    "-Xms${MEMORY}G"
    "-Dfile.encoding=UTF-8"
    "-Dcom.mojang.eula.agree=true"
  )

  case $JVM_TYPE in
    "hotspot")
      [[ -f "args.hotspot" ]] || wget -q -c --content-disposition -P . -N "$REPO_BASE_URL/$REPO_BRANCH/deploy/args/args.hotspot" > /dev/null
      source args.hotspot;;
    "openj9")
      [[ -f "args.openj9" ]] || wget -q -c --content-disposition -P . -N "$REPO_BASE_URL/$REPO_BRANCH/deploy/args/args.openj9" > /dev/null
      source args.openj9;;
    *)
      # display JVM runtime detection error to stderr
      echo "Unable to detect JVM Runtime type. Continuing without JVM GC Optimization flags." 1>&2;;
  esac
  
  if [[ $DEBUG_PORT -gt -1 ]]; then
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

    if [ "$(printf '%s\n' "$java_version" "9" | sort -V | head -n1)" = "9" ]; then
      echo "DEBUG MODE: JDK9+"
      jvm_arguments+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:$DEBUG_PORT")
    else
      echo "DEBUG MODE: JDK8"
      jvm_arguments+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT")
    fi
  fi

  jvm_arguments+=(
    "-jar"
    "$JAR"
    "--nogui"
  )

    [[ $PLAYERS -gt -1 ]] && jvm_arguments+=("-s$PLAYERS")
    [[ ! -z $PLUGINS ]] && jvm_arguments+=("-P$PLUGINS")
    [[ ! -z $WORLDS ]] && jvm_arguments+=("-W$WORLDS")
    [[ $PORT -gt -1 ]] && jvm_arguments+=("-p$PORT")

  echo "Parameters: ${jvm_arguments[@]}"

  java "${jvm_arguments[@]}"

  if [[ $BACKUP = true ]]; then
    read -r -t 5 -p "Press Enter to start the backup immediately or Ctrl+C to cancel `echo $'\n> '`"
    echo 'Start the backup.'
    backup_file_name=$(date +"%y%m%d-%H%M%S")
    mkdir -p '.backup'
    tar --exclude='./.backup' --exclude='*.gz' --exclude='./cache' -zcf ".backup/$backup_file_name.tar.gz" .
    echo 'The backup is complete.'
  fi

  if [[ -f ".start" ]]; then
    continue
  elif [[ $RESTART = true ]]; then
    read -r -t 3 -p "The server restarts. Press Enter to start immediately or Ctrl+C to cancel `echo $'\n> '`"
    continue
  else
    break
  fi
done
