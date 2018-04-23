# Raspberry Pi Status Updater
### Author: Ashley Cawley // [@ashleycawley](https://twitter.com/ashleycawley)

This script is designed to get the client computer (Raspberry Pi) to publish
its status to a central (web) server, with the idea of multiple different systems
all publishing their status to that central server so that the Administrator has
one easy place to view the general health and uptime of the systems or IOT devices.

An example of some of data the client system would publish would be:
- Hostname
- Uptime
- Load
- Logged on Users
- LAN IP Address
- WAN IP Address
- MAC Address
- CPU Temperature
- GPU temperatures
- Free disk space

Whilst this script will install itself it does require the you to specify some
settings in order to configure it properly, this is explained in more detail below.

## Self Installer
The Bash script contains a self-installer, it checks to see if it is already present
in /usr/local/bin and if it is not then it copies itself to that location and then
schedules a task (via the crontab) to trigger itself on a regular basis (eg. hourly).

## Setup

# This is a work in progress
So at this point I would probably recommend not following these setup instructions.

### Prerequisites
For this project to work you will need:
- A Web Hosting service that allows SSH access
- An ability to setup Key-Based Authentication for SSH
- A Raspberry Pi (or other Linux sytem you wish to monitor)
- Ability to edit a script to change some easy settings (variables)

### 1) Download the update-status.sh script to your system:
wget https://raw.githubusercontent.com/ashleycawley/raspberry-pi-status/master/update-status.sh

### 2) Edit the update-status.sh script and configure the settings:

REMOTESERVER="status.YourWebServer.co.uk" (The hostname of your Remote Web Server)
USERNAME=pistatus (This is the username on the Remote Server)
