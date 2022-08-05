# Minecraft server launcher script (Shell)
## Dependencies
* java
* wget
* [**jq**](https://stedolan.github.io/jq/)
* git (Spigot only)
* tar (Optional)
* bash 4.0+

## Installation

> 😪 **TL;DR**  
> Install dependencies, and copy paste this to your terminal:  
> ```bash
> curl -L https://s4a.it/mc-setup | bash
> ```

1. Install JVM Runtime of your choice 
   - Make sure it is available via `PATH` environment variable.  
     Verify it via `whereis java`.  

2. Install Dependencies
   > The following scripts does not install Java Runtime. Install JRE if you don't have one installed beforehand.
   - Ubuntu/Debian:
     ```bash
     sudo apt install jq git wget tar
     ```
   - Fedora/CentOS/RHEL-based Linux:
     ```bash
     sudo yum install jq git wget tar
     ```
   - Arch Linux (Manjaro, SteamOS, etc.):  
     ```bash
     sudo pacman -Sy jq git wget tar
     ```
   - macOS (with [Homebrew](https://brew.sh))
     > Considering other dependencies are installed via XCode Developer Tools (`xcode-select --install`)
     ```bash
     brew install jq wget
     ```
   - Windows (with [Chocolatey](https://chocolatey.org/install))
     ```bash
     choco install -y wget jq
     ```
     > If you don't have Java 17 installed. You can install it via Chocolatey (Azul Zulu, Hotspot)
     > ```bash
     > choco install -y zulu17
     > ```

3. (Optional) Download `settings.env` to configure server
   1. Download [settings.env](https://raw.githubusercontent.com/Alex4386/minecraft-server-launcher/master/settings.env) and place it into your server directory
      * wget
        ```bash
        wget https://raw.githubusercontent.com/Alex4386/minecraft-server-launcher/master/settings.env
        ```

      * curl
        ```bash
        curl -o settings.env https://raw.githubusercontent.com/Alex4386/minecraft-server-launcher/master/settings.env
        ```
  
   2. Modify the downloaded `settings.env` to match with your system specs

4. Run script
   1. Automatic install
      * wget
        ```bash
        wget -O - https://s4a.it/mc-setup | bash
        ```

      * curl
        ```bash
        curl -L https://s4a.it/mc-setup | bash
        ```

      After the automatic install, `./run` will be generated automatically on your server directory. You can use `./run` to start your server after installation.

   2. Manual install
      1. Download [run](https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run) script to your server directory
      2. Give executable permissions with `chmod +x ./run`.
      3. `./run`

## Note
* Server jar files are in `~/.mcservers/`
* Spigot builds using [**BuildTools**](https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar). It may take a few minutes.

## License
[MIT License](LICENSE.md)
