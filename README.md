# Minecraft server launcher script (Shell)

## Dependencies

* java
* wget
* [**jq**](https://stedolan.github.io/jq/)
* git (Spigot only)
* tar (Optional)

## Installation

1. Install JVM Runtime of your choice
    - Make sure it is available via `PATH` environment variable.  
      Verify it via `whereis java`. (*NIX systems only)

    - On Windows, You can install it via [Chocolatey](https://chocolatey.org/install)
      ```bash
      choco install -y zulu17
      ```

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
3. Run script
    1. Automatic install
        1. (Optional) Configure your server by setting your environment variables (Refer
           to [settings.env](/settings.env))
            * wget
              ```bash
              wget https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/settings.env
              set -a; source settings.env; set +a
              ```

            * curl
              ```bash
              curl -o settings.env https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/settings.env
              set -a; source settings.env; set +a
              ```

        2. Run following one-liner script to install

        * wget
          ```bash
          bash <(wget -O - https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run)
          ```

        * curl
          ```bash
          bash <(curl -L https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run)
          ```

       After the automatic install, `./run` will be generated automatically on your server directory. You can
       use `./run` to start your server after installation. (Don't forget to set environment variables before you run (
       e.g. load from file: `set -a; source settings.env; set +a`))

    2. Manual install
        1. Download [run](https://raw.githubusercontent.com/monun/minecraft-server-launcher/master/run) script to your
           server directory
        2. Give executable permissions with `chmod +x ./run`.
        3. (Optional) Configure your server by modifying `./run` or your environment variables (Refer
           to [settings.env](/settings.env))
        4. Run script by `./run`

## Note

* Server jar files are in `~/.mcservers/`
* Spigot builds using [**
  BuildTools**](https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar). It
  may take a few minutes.

## License

[MIT License](LICENSE.md)
