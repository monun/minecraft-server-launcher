# Minecraft server launcher script (Shell)
## Requirements
* wget
* [**jq**](https://stedolan.github.io/jq/)
* java
* tar (Optional)
## Installation
1. Download required programs.
2. `wget https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/launch.sh` Download [**launch.sh**](https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/launch.sh) to the server path.
3. `chmod +x ./launch.sh` to allow executable permissions.
4. Modify the configuration of launch.sh (Optional)
5. `./launch.sh` to run the server.
## Note
* Server jar files are in `~/.mcservers/`
* Spigot builds using [**BuildTools**](https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar). It may take a few minutes.
## Tips
* for Windows Users
  * Use WSL or git bash.
  * [**Chocolatey**](https://chocolatey.org/install) is easy to manage packages.
    * `choco install -y wget jq zulu17`