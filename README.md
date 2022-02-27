# GPSInfo

GPSInfo is a utility for Sailfish OS to check the details of the GPS positioning system. It can tell you your location, speed, direction, the signal strength of the satellites and a lot more!

This project is a fork of [balta3/sailfish-gpsinfo](https://github.com/balta3/sailfish-gpsinfo) and is available for download from [OpenRepos.net](https://openrepos.net/content/direc85/gpsinfo).

# Compiling

To compile GPSInfo for yourself, you'll have to clone the repo, initialize and update the subcodules:

```bash
$ git clone git@github.com:direc85/harbour-gpsinfo.git
$ cd harbour-gpsinfo
$ git submodule init
$ git submodule update
```

Open up the project file in Sailfish IDE, configure the project and hit run!

Alternatively, you can compile it using [sfdk](https://docs.sailfishos.org/Develop/Apps/Tutorials/Building_packages_-_advanced_techniques/);

```bash
$ cd harbour-gpsinfo

# Path to sfdk binary
$ set PATH=$PATH:~/SailfishOS/bin

# Sailfish version and architecture of your choice
$ sfdk config --push target SailfishOS-4.3.0.12-aarch64 && sfdk build
```

# Translations

GPSInfo is build originally to support manual language setting. How this is handled build time has changed a few times, but the current approach looks like to be simple: just build and run!

If the setting in the menu doesn't seem to have any effect, try building the package, commenting `sailfish_i18n` line in the project file, and building the package again.
