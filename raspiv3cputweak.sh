#!/bin/bash

# Built on 9th Mars 2016
# By Constantin Busuioceanu
# Smart_Raspiv3CPUtweak - for Raspberry Pi 3
# View Raspberry Pi 3 CPU Info - Clock speed - Temperatures - Voltage - Overclock you RPi - Change Governor & more
# Run script with sudo raspiv3cputweak.sh
#
# Have fun tweaking your RPi
#
# Warning: by using this software (script), you understand that I can't be held
# responsible for anything that may happen.
# If you OC you RPi, I recommend using heatsinks!!!
# WARNING: You MUST USE a good power supply with min 2.5A !!!

# This script/program has been fully tested!

#### COLOR SETTINGS ####
BLACK=$(tput setaf 0 && tput bold)
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
YELLOW=$(tput setaf 3 && tput bold)
BLUE=$(tput setaf 4 && tput bold)
MAGENTA=$(tput setaf 5 && tput bold)
CYAN=$(tput setaf 6 && tput bold)
WHITE=$(tput setaf 7 && tput bold)
BLACKbg=$(tput setab 0 && tput bold)
REDbg=$(tput setab 1 && tput bold)
GREENbg=$(tput setab 2 && tput bold)
YELLOWbg=$(tput setab 3 && tput bold)
BLUEbg=$(tput setab 4 && tput dim)
MAGENTAbg=$(tput setab 5 && tput bold)
CYANbg=$(tput setab 6 && tput bold)
WHITEbg=$(tput setab 7 && tput bold)
STAND=$(tput sgr0)

### System dialog VARS
showinfo="$GREEN[info]$STAND"
showerror="$RED[error]$STAND"
showexecute="$YELLOW[running]$STAND"
showok="$MAGENTA[OK]$STAND"
showgrnok="$GREEN[OK]$STAND"
showrqst="$CYAN[input]$STAND"
showexpired="$REDbg$WHITE[EXPIRED]$STAND"
showactive="$GREENbg$WHITE[ACTIVE]$STAND"
showwarning="$RED[warning]$STAND"
showremove="$GREEN[removing]$STAND"
shownone="$MAGENTA[none]$STAND"
redhashtag="$REDbg$WHITE#$STAND"
##

version="01/30/2018"
unixtime=$(date --date="$version" +"%s")
time=$(date +"%T")

### Resize current window
function resizewindow(){
echo "$showinfo Resizing window to$GREEN 24x90"$STAND
resize -s 24 125 1> /dev/null
}

#### ROOT User Check
function checkroot(){
	if [[ $(id -u) = 0 ]];
	then
		echo -e "$showinfo Checking for ROOT:$GREEN PASSED"$STAND
	else
		echo -e $WHITE" Checking for ROOT:$RED FAILED - This Script Needs To Run As$RED ROOT (sudo)\n" $STAND
		echo -e $WHITE" Raspiv3CPUtweak will Exit.\n"$STAND
		exit 0
	fi
}


function sversion(){
echo "$showinfo Script version:$GREEN $version"$STAND
}

#### pause function
function pause(){
	local message="$@"
	[ -z $message ] && message=$STAND"Press [Enter] key to continue..."
	read -e -p "$message" readEnterKey
}

#### Dependencies check

function checkdependencies(){
####################################################################################
#                Path to installations			                           #
####################################################################################
findxterm="/lib/terminfo/x/xterm"    # installation path to xterm (for resize cmd) #
findvcgencmd="/opt/vc/bin/vcgencmd" # installation path to xterm                   #
####################################################################################

	# -------------------------------------------
	# Check for installed dependencies
	# -------------------------------------------
	if [ -a /tmp/smart_raspiv3cputweak ];
	then
		echo "$showexecute Checking dependencies: ${GREEN}PASSED"$STAND
	else
		echo "dependencies_OK" > /tmp/smart_raspiv3cputweak
		echo "$showexecute Checking dependencies..."

		#### check if xterm installation exists
		if [ -e $findxterm ];
		then
			echo "$showok[xterm]:$WHITE installation found..."
			apt-get install -y xterm > /dev/null
		else
			echo "$showwarning: This script requires xterm installed to work"
			echo "$showexecute Downloading from network..."
			sleep 2;
			apt-get install -y xterm
		fi
			sleep 1;
		####

		#### check if vcgencmd installation exists
		if [ -e $findvcgencmd ];
		then
			echo $BLUE"$showok[vcgencmd]:$WHITE installation found..."
		else
			echo "$showwarning: This script requires vcgencmd installed to work"
			echo "$showexecute Downloading from network..."
			sleep 2;
			sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
		fi
		sleep 1;
		###
			echo "$showinfo All dependencies ok..."
	fi
}
resizewindow && checkroot && sversion && checkdependencies
###


### Check Frequency, Temp, Voltage, Governor
function freqtempvolt() {

function mhz_convert() {
    let value=$1/1000
    echo "$value"
}

function overvoltdecimals() {
    let overvolts=${1#*.}-20
    echo "$overvolts"
}

temp=$(vcgencmd measure_temp)
temp=${temp:5:4}

volts=$(vcgencmd measure_volts)
volts=${volts:5:4}

if [ $volts != "1.20" ]; then
    overvolts=$(overvoltdecimals $volts)
fi

### VARS
minFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
minFreq=$(mhz_convert $minFreq)
maxFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
maxFreq=$(mhz_convert $maxFreq)
freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
freq=$(mhz_convert $freq)
governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
transitionlatency=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency)
###

	if [ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) == ondemand ];
	then
		### VARS
		samplingrate=$(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)
		#samplingratemin=$(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate_min)
		upthreshold=$(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)
		###

		echo -e "\n+------------------------------------+"
		echo "Temperature:        $temp C"

		if [ $volts == "1.20" ]; then
			echo "Voltage:            $volts V"
		else
			echo -n "Voltage:            $volts V"
			[ $overvolts ] && echo " (+0.$overvolts overvolt)" || echo -e "\n"
		fi

		echo "Min speed:          $minFreq MHz"
		echo "Max speed:          $maxFreq MHz"
		echo "Current speed:      $freq MHz"
		echo "Governor:           $governor"
		echo "Sampling rate:      $samplingrate"
		echo "Up threshold:       $upthreshold"
		echo "Transition latency: $transitionlatency"
		echo "+------------------------------------+"
	else
		echo -e "\n+------------------------------------+"
		echo "Temperature:        $temp C"

		if [ $volts == "1.20" ]; then
			echo "Voltage:            $volts V"
		else
			echo -n "Voltage:            $volts V"
			[ $overvolts ] && echo " (+0.$overvolts overvolt)" || echo -e "\n"
		fi

		echo "Min speed:          $minFreq MHz"
		echo "Max speed:          $maxFreq MHz"
		echo "Current speed:      $freq MHz"
		echo "Governor:           $governor"
		echo "Transition latency: $transitionlatency"
		echo "+------------------------------------+"
	fi
		pause
}

### Change GOVERNOR settings
function changegovernor() {

### VARS
affected_cpus=$(cat /sys/devices/system/cpu/cpu0/cpufreq/affected_cpus)
available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
current_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
###

echo -e "\n$showinfo Current CPU governor is:$GREEN $current_governor"$STAND
echo "$showinfo Affected cpus:$GREEN $affected_cpus"$STAND
echo "$showinfo Available CPU governors:$RED $available_governors"$STAND
echo "$showinfo If you'd like to abort, write abort then press enter."
read -e -p "$showrqst Enter desired governor: " ch_governor

if [[ $ch_governor == "abort" ]];
then
	echo "$showexecute Going back to main menu." && sleep 1
else
	sudo sh -c "echo $ch_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
	echo -e "$showinfo Governor changed to:$RED $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)\n"$STAND

	if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) == ondemand ]];
	then
		echo "Ondemand governor set. You can change sampling_rate and up_threshold for better performance."
		echo "Current sampling_rate=$GREEN $(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)"$STAND
		#read -p "Enter new sampling_rate value: " sampling_rate
		#sudo sh -c "echo $sampling_rate > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate"
		#echo "sampling_rate changed to:$RED $(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)"$STAND

		echo "According to Kernel Documentation, sampling_rate should get adjusted considering the transition latency."
		echo "The default model looks like this: cpuinfo_transition_latency * 1000 / 1000 = sampling_rate"

		echo "The next operation will do this for you. For example, we can choose 750"
		read -e -p "$showrqst Enter value: " sampling_rate_value
		sudo sh -c "echo $(($(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency) * $sampling_rate_value / 1000)) > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate"
		echo "sampling_rate changed to:$RED $(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)"$STAND

		echo -e "Current up_threshold=$GREEN $(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)\n"$STAND
		read -e -p "$showrqst Enter new up_threshold value: " up_threshold
		sudo sh -c "echo $up_threshold > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold"
		echo -e "up_threshold changed to:$RED $(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)\n"$STAND
		pause
	else
		pause
	fi
fi
}

### Overclocking settings
function rpioverclock() {
clear
read -e -p "$showrqst Write$GREEN overclock$STAND to continue or$RED abort$STAND to cancel: " oc_accept
	if [[ $oc_accept == overclock ]];
	then
		echo "Creating backup for config.txt in /boot"
		echo "You will have an option to post-edit/review your config.txt and add personal settings before restarting."
	sleep 1
		sudo cp /boot/config.txt /boot/config.txt.raspicputweak-backup
		sudo echo "hdmi_force_hotplug=1
arm_freq=1400
arm_freq_min=700
core_freq=500
sdram_freq=500
over_voltage=6" > /boot/config.txt

		echo "$showexecute Mods written."
		echo "$showinfo Please review mods..." && sleep 1
		sudo nano /boot/config.txt
		echo -e "\nAll ok."
		pause
	else
		echo -e "\n$showinfo Going back to main menu." && sleep 1
		#rpioverclock
	fi
}

#### Raspiv3CPUtweak CHANGELOG
function raspitweakchangelog(){
### VARS
checknet=$(ping -q -w 1 -c 1 google.com 2>&1 > /dev/null && echo Internet OK.)
###
	if [[ "$checknet" == "Internet OK." ]];
	then
	### VARS
	changelog=$(curl --silent --user-agent "SmartUniverseTechnologies - Smart_Raspiv3CPUtweak - smartuniversetech.ro" -q https://www.smartuniversetech.ro/linux-scripts/updates/smart_raspiv3cputweak/changelog.txt)
	last_version=$(curl --silent --user-agent "SmartUniverseTechnologies - Smart_Raspiv3CPUtweak - smartuniversetech.ro" -q https://www.smartuniversetech.ro/linux-scripts/updates/smart_raspiv3cputweak/version.txt)
	###

		if [[ $last_version > $unixtime ]];
		then
			clear && echo -e $GREEN"\nChecking for update: $REDbg${WHITE}New version available!\n"$STAND
			echo $YELLOW"Changelog:$MAGENTA
$changelog" $STAND
			echo -e $REDbg$WHITE"\nNew version available!\n"$STAND
			echo $MAGENTAbg$WHITE"Get the latest version from https://www.smartuniversetech.ro"$STAND

			read -e -p "$showrqst Press y to open website or n to go to Main Menu." option
			case $option in
		  		y) xdg-open "https://www.smartuniversetech.ro/?s=raspberry pi v3 cpu tweak" 2> /dev/null && clear ;;
				n) clear ;;
     				*) echo " \"$option\" Is Not A Valid Option"; sleep 1; raspitweakchangelog ;;
		    	esac
		else
			clear && echo -e $GREEN"\nChecking for update:$YELLOW You already have the latest version!" $STAND
    			sleep 2 && clear
		fi
	else
		echo -e $STAND"\nNo Internet connection." && sleep 2
		clear
	fi
}

#### Exit Raspiv3CPUtweak
function exitcputweak () {
  echo "Bye!"
  exit 0
}

#### Infinite Loop To Show Menu Until Exit
#trap '{ echo "CTRL C Detected. Closing script..."; exit 0; }' SIGINT

while :
do
echo $YELLOW"+-----------------------------------+"
echo "|Raspberry Pi 3 CPU Tweaker         |
|Script version: $version         |"
echo "+-----------------------------------+"$STAND
echo "+------------------------------+"
echo "| 1. Show CPU details          |"
echo "| 2. Change CPU Govenor        |"
echo "| 3. ${RED}Overclock$STAND                 |"
echo "| 4. Updates                   |"
echo "| 5. EXIT                      |"
echo "+------------------------------+"
read -e -p "$showrqst Choose an option: " menuoption

case $menuoption in
1) freqtempvolt ;;
2) changegovernor ;;
3) rpioverclock ;;
4) raspitweakchangelog ;;
5) exitcputweak ;;
*) echo "'$menuoption' Is not a valid option!" && sleep 1; clear ;;
esac
done

#End
