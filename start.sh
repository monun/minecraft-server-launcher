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
  echo "JVM_HOTSPOT=$JVM_HOTSPOT"
  echo "JVM_HOTSPOT=$JVM_HOTSPOT"

  # Common JVM Arguments
  jvm_arguments=(
    "-Xmx${MEMORY}G"
    "-Xms${MEMORY}G"
    "-Dfile.encoding=UTF-8"
    "-Dcom.mojang.eula.agree=true"
  )
  
  if [[ "$JVM_HOTSPOT" == "hotspot" ]]; then
    jvm_arguments+=(
      "-XX:+ParallelRefProcEnabled"
      "-XX:MaxGCPauseMillis=200"
      "-XX:+UnlockExperimentalVMOptions"
      "-XX:+DisableExplicitGC"
      "-XX:+AlwaysPreTouch"
      "-XX:G1HeapWastePercent=5"
      "-XX:G1MixedGCCountTarget=4"
      "-XX:G1MixedGCLiveThresholdPercent=90"
      "-XX:G1RSetUpdatingPauseTimePercent=5"
      "-XX:SurvivorRatio=32"
      "-XX:+PerfDisableSharedMem"
      "-XX:MaxTenuringThreshold=1"
      "-Dusing.aikars.flags=https://mcflags.emc.gs"
      "-Daikars.new.flags=true"
    )
    
    if [[ $MEMORY -lt 12 ]]; then
      echo "Use Aikar's standard memory options"
      jvm_arguments+=(
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:InitiatingHeapOccupancyPercent=15"
      )
    else
      echo "Use Aikar's Advanced memory options"
      jvm_arguments+=(
        "-XX:G1NewSizePercent=40"
        "-XX:G1MaxNewSizePercent=50"
        "-XX:G1HeapRegionSize=16M"
        "-XX:G1ReservePercent=15"
        "-XX:InitiatingHeapOccupancyPercent=20"
      )
    fi
  elif [[ $JVM_TYPE == "openj9" ]]; then
    # Nursery configuration
    MEMORY_MEGA=$(($MEMORY * 1024))
    
    # Recommended memory setup by
    # https://gist.github.com/Artuto/2cf3d419407aee2567f91683682300ad
    MEMORY_NURSERY_MIN=$(($MEMORY_MEGA / 2))
    MEMORY_NURSERY_MAX=$(($MEMORY_MEGA / 5 * 4)) 
    
    # Override values to match nursery range with Aikar's. 
    # Comment out to use recommended nursery above.
    if [[ $MEMORY -lt 12 ]]; then
      echo "Using standard Nursery memory allocation"
      MEMORY_NURSERY_MIN=$(($MEMORY_MEGA / 10 * 3))
      MEMORY_NURSERY_MAX=$(($MEMORY_MEGA / 10 * 4))    
    else
      echo "Using extended Nursery memory allocation"
      MEMORY_NURSERY_MIN=$(($MEMORY_MEGA / 10 * 4))
      MEMORY_NURSERY_MAX=$(($MEMORY_MEGA / 10 * 5))
    fi
    
    jvm_arguments+=(
      "-Xmns${MEMORY_NURSERY_MIN}M"
      "-Xmnx${MEMORY_NURSERY_MAX}M"
    )
    
    jvm_arguments+=(
      # Disable explicit GC
      "-Xdisableexplicitgc"
    
      # Use Gencon GC for short-lived memory allocs
      "-Xgcpolicy:gencon"
      
      # minimize pause time during GC
      "-Xgc:concurrentScavenge"
      
      # set maximum GC pause time to 3% of runtime
      "-Xgc:dnssExpectedTimeRatioMaximum=3"
      
      # Disable Adaptive Tenture in gencon GC
      "-Xgc:scvNoAdaptiveTenure"
    )

    # TODO: -Xtune:virtualized flag if system is virtualized.
    VIRTUALIZED=0

    if [[ $VIRTUALIZED -eq 1 ]]; then
      jvm_arguments+=(
        "-Xtune:virtualized"
      )
    fi

  else
    # display JVM runtime detection error to stderr
    echo "Unable to detect JVM Runtime type. Continuing without JVM GC Optimization flags." 1>&2
  fi
  
  
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
