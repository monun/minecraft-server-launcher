# Minecraft server launcher script (Shell)
## Requirements
* java
* wget
* [**jq**](https://stedolan.github.io/jq/)
* git (Spigot only)
* tar (Optional)
## Installation
1. Download required programs.
2. `wget https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run` Download [**run**](https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run) to the server path.
3. `chmod +x ./run` to allow executable permissions.
4. Modify the configuration of run (Optional)
5. `./run` to run the server.
## Note
* Server jar files are in `~/.mcservers/`
* Spigot builds using [**BuildTools**](https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar). It may take a few minutes.
## Tips
* for Windows Users
  * Use WSL or git bash.
  * [**Chocolatey**](https://chocolatey.org/install) is easy to manage packages.
    * `choco install -y wget jq zulu17`
