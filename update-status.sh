#!/bin/bash
#
# Author: Ashley Cawley // @ashleycawley // ash@ashleycawley.co.uk
#
## Variables
PROGNAME=update-status.sh
PROGRAMPATH=/usr/local/bin
TEMP=/tmp
RANDOMDELAY=30
REMOTESERVER="status.ashleycawley.co.uk"
USERNAME=pistatus
SERVERPATH="/home/$USERNAME/public_html/pies/"
SLEEP="sleep 0"
WANIPLOOKUP="$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')"
MAC=$(sudo cat /sys/class/net/wlan0/address 2>/dev/null)
TEMPLATE=('echo <html>
<head>
</head>
<body>
<font face="verdana">
        <h1>HOSTNAME</h1>
                <p align="left">
<font size="2">
Reporting in on DATE</br></br>
ONLINEFOR</br></br>
<strong>Load:</strong> LOADAVG</br></br>
<b>Users currently logged on:</b> USERSLOGGEDON</br></br>
<b>LAN IP:</b> LOCALIP</br></br>
<b>WAN IP:</b> WANIP</br></br>
<b>MAC Address:</b> MACADDRESS</br></br>
<b>Temperatures</b></br>
        <br>
CPUTEMP
        <br>
GPUTEMP
        </br></br>

<b>Free Disk Space:</b> FREEDISK

        </br></br>

<b>System Information:</b> SYSINFO
                </p>
</font>
</body>
</html>')
#
## Functions
#
# Looks up the local IP address
function LANIP {
	hostname -I | awk '/192/ {print $1;}'
}

# Creates the Log Folder
function CREATELOGFOLDER {
	mkdir -p $HOME/$PROJECTPATH/logs
}

# Installs the script into the crontab
function INSTALLCRON {
	echo "Saving the current crontab..." && echo
        crontab -l > /tmp/crons

	echo "Updating file to contain new CRON task..." && echo
	echo "0 * * * * bash $PROGRAMPATH/$PROGNAME" >> /tmp/crons

	echo "Installing new CRON task file in to crontab" && echo
	crontab /tmp/crons

	echo "Removing temporary CRON file..." && echo
	rm /tmp/crons
}


############
## Script ##
############

# Performs test to see if Private Key is installed for Remote Server communication
grep -r "net8xYdLIdXouObZos3Zn8V" ~/.ssh/ &>/dev/null
	if [ $? == '1' ]
		then
			echo
			echo "### WARNING ###"
			echo "Private key is not installed, this script cannot communicate with the remote server."
			echo "Please install the private SSH key at $HOME/.ssh/id_rsa"
			echo
			exit 1
	fi


###############################################################################################
# This is my Installer Sub-Script, the above performs a test to see if the program is already #
# installed if it is not then it performs the below to install it, then continues on.         #
###############################################################################################

until [ -e $PROGRAMPATH/$PROGNAME ]
	do
		if
       		[ `whoami` == pi ]
		then
			echo "" && echo "----------------------------------------------" && echo ""
			echo "It has been detected that the $PROGNAME script is not presently installed on this system."
			echo "We are proceeding to install it now for future use..."
			sleep 5 && echo

			echo "Copying the program to $PROGRAMPATH"
			sudo cp -f $0 $PROGRAMPATH/ 
			sudo chmod +x $PROGRAMPATH/$PROGNAME
			sleep 2 && echo

			# CREATELOGFOLDER # This function creates the log folder, the function is declared toward the top.

			echo "Installing CRON task..." && echo && sleep 2
			INSTALLCRON # Uses the INSTALLCRON function which is declared toward the top of this script.

		fi
	done

####################
## Installed Ends ##
####################

##################################
## Normal Runtime Script Begins ##
##################################

echo "----------------------------------------------" && echo ""
echo "Status Update Script Starting on `date`"
# CREATELOGFOLDER # This function creates the log folder, the function is declared toward the top.
echo "" && $SLEEP


# This introduces a random delay in to the mix so that multiple nodes do not interfer
# with one another by trying to update the files on the central server at the same time.
echo "Introducing a random delay which could be anywhere from 1-$RANDOMDELAY seconds"
sleep $((RANDOM % $RANDOMDELAY))
echo "" && $SLEEP

# Tests to see if the script is already in the crontab and if not installs it in there
crontab -l | grep "$PROGNAME" 1>/dev/null

# Tests the exit status code from the command above, if it equals 1 it installs cron.
if [ $? = 1 ]
	then
		INSTALLCRON # Uses the INSTALLCRON function which is declared toward the top of this script.
fi


# Creates Temporary working folder
echo "Creating Temporary Working Area..."
mkdir -p /tmp/status/
echo "" && $SLEEP


# Calculating CPU & GPU Temperatures & storing them for later use.
echo "Calculating CPU & GPU Temperatures"
cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))
gpuTemp0=$(/opt/vc/bin/vcgencmd measure_temp)
gpuTemp0=${gpuTemp0//\'/}
gpuTemp0=${gpuTemp0//temp=/}
echo CPU: $cpuTemp1"."$cpuTempM"C" > $TEMP/CPUTEMP
echo GPU: $gpuTemp0 > $TEMP/GPUTEMP
echo "" && $SLEEP


# Copies template.html to index.html and then updates index.html with stats info.
echo "Performing Search & Replace to update Template and build HTML status page..."
rm -f $TEMP/index.html # Performing clean-up of files potentially left over from last run.

# Outputs the Template HTML page from the TEMPLATE varaible into a file in /tmp/index.html
$TEMPLATE > $TEMP/index.html

# Modifies the file by doing a search and replace filling in the attributes with up to date stats
sed -i s/HOSTNAME/`hostname`/g $TEMP/index.html # Sets Hostname
sed -i s/DATE/"`date +"%T %a %d %b %Y"`"/g $TEMP/index.html # Sets Date
uptime -p > $TEMP/ONLINEFOR
sed -i s/up/"Online for"/g $TEMP/ONLINEFOR # Sets Uptime / Online for x hours and seconds.
sed -i s/ONLINEFOR/"`cat $TEMP/ONLINEFOR`"/g $TEMP/index.html
rm -f $TEMP/ONLINEFOR
sed -i s/LOADAVG/`uptime | awk '/load average:/ { print $10 $11 $12 }'`/g $TEMP/index.html
sed -i s/MACADDRESS/`echo $MAC`/g $TEMP/index.html # Sets MAC Address
sed -i s/CPUTEMP/"`cat $TEMP/CPUTEMP`"/g $TEMP/index.html # Sets CPU Temp
rm -f $TEMP/CPUTEMP
sed -i s/GPUTEMP/"`cat $TEMP/GPUTEMP`"/g $TEMP/index.html # Sets GPU Temp
rm -f $TEMP/GPUTEMP
sed -i s/LOCALIP/`LANIP`/g $TEMP/index.html
sed -i "s|SYSINFO|`uname -a`|g" $TEMP/index.html
rm -f $TEMP/SYSINFO
sed -i s/USERSLOGGEDON/"`users`"/g $TEMP/index.html # Shows logged on users.
sed -i s/WANIP/`host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}'`/g $TEMP/index.html
sed -i "s|FREEDISK|`df -h | grep -vE '^Filesystem|tmpfs|cdrom|mmcblk0p1' | awk '{ print $4 " " $1 }'`|g" $TEMP/index.html

echo "" && $SLEEP


# Syncronises copy of Remote Files to Local Temporary Working Directory at /tmp/status
echo "Syncronising Files on Remote Server to Local Temp Directory at /tmp/status/"
rsync --progress -avz -e 'ssh -p 2223 -o StrictHostKeyChecking=no' $USERNAME@$REMOTESERVER:$SERVERPATH /tmp/status/
echo "" && $SLEEP


# Performing a test to see if a status update from this system already exists
grep -rl `hostname` /tmp/status/


# The test below checks to see if the exit status code from the command above is either 0 or 1
if [ $? = 0 ]
         then
		echo "A file on the Remote Server already contains a status update, I will overwrite that file..."


		# Retrieves the Existing Filename from the Remote Server to use Later
		EXISTING_FILENAME=$(grep -rl `hostname` /tmp/status/ | awk -F '/' '{ print $4 }')
		echo "" && $SLEEP

		echo "The existing filename is:"
		echo "$EXISTING_FILENAME"
		echo "" && $SLEEP

		
		# Uploads status webpage to the Remote Server
		echo "Uploading HTML page to $REMOTESERVER"
		scp -P 2223 -o StrictHostKeyChecking=no $TEMP/index.html $USERNAME@$REMOTESERVER:/home/$USERNAME/public_html/pies/`echo $EXISTING_FILENAME` 2>/dev/null
		echo "" && $SLEEP


		# Clean up temporary working area
		echo "Cleaning up temporary working area..."
		rm -fr /tmp/status/
		rm -f $TEMP/index.html
		echo "" && $SLEEP
		echo "Script has finished."
		echo "" && echo "----------------------------------------------"
	exit 0
else

	echo "The server does not contain a previous status update from this system. Creating a new file..."


	# Calculates the number of files stored on the Remote Server & Stores is in the COUNTER variable
	echo "Looking at the number of status files held on the Remote Server..."
	COUNTER=`ls -1 /tmp/status/ | wc -l`
	echo "" && $SLEEP


	# Increments the COUNTER variable by +1
	echo "On the server there are $COUNTER files"
        ((COUNTER=COUNTER+1))
	echo "Add 1 to that and now you have $COUNTER"
	echo "" && $SLEEP


	# Uploads status webpage to the Remote Server
	echo "Uploading HTML page to $REMOTESERVER"
	scp -P 2223 $TEMP/index.html $USERNAME@$REMOTESERVER:/home/$USERNAME/public_html/pies/pi$COUNTER.html 2>/dev/null
	echo "" && $SLEEP

	# Clean up temporary working area
	echo "Cleaning up temporary working area..."
	rm -fr /tmp/status/
	rm -f $TEMP/index.html
	echo "" && $SLEEP


	echo "Script has finished."
	echo "" && echo "----------------------------------------------"

	exit 0
fi
exit 0
