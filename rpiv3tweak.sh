#!/bin/bash

# Built on 9th March 2016
# RPiv3Tweak - for Raspberry Pi 3
# View Raspberry Pi 3 CPU Info - Clock speed - Temperatures - Voltage - Overclock you RPi - Change Governor & more
# Run script with sudo bash raspiv3cputweak.sh
#
# Have fun tweaking your RPi
#
# Warning: by using this software (script), you understand that I can't be held
# responsible for anything that may happen.
# If you OC you RPi, I recommend using heatsinks!!!
# NOTE: You MUST USE a good power supply with min 2.5A !!!

# MIT License
# Copyright (c) 2020 CONSTANTIN BUSUIOCEANU

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

###
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi
###

#### COLOR SETTINGS ####
#BLACK=$(tput setaf 0 && tput bold)
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
YELLOW=$(tput setaf 3 && tput bold)
#BLUE=$(tput setaf 4 && tput bold)
MAGENTA=$(tput setaf 5 && tput bold)
CYAN=$(tput setaf 6 && tput bold)
WHITE=$(tput setaf 7 && tput bold)
#BLACKbg=$(tput setab 0 && tput bold)
REDbg=$(tput setab 1 && tput bold)
#GREENbg=$(tput setab 2 && tput bold)
#YELLOWbg=$(tput setab 3 && tput bold)
#BLUEbg=$(tput setab 4 && tput dim)
#MAGENTAbg=$(tput setab 5 && tput bold)
#CYANbg=$(tput setab 6 && tput bold)
#WHITEbg=$(tput setab 7 && tput bold)
STAND=$(tput sgr0)

### System dialog VARS
show_info="${GREEN}[info]$STAND"
show_error="${RED}[error]$STAND"
show_execute="${YELLOW}[running]$STAND"
show_ok="${MAGENTA}[OK]$STAND"
show_input="${CYAN}[input]$STAND"
show_warning="${RED}[warning]$STAND"
##

version="09/25/2020"
unixtime=$(date --date="$version" +"%s")
#time=$(date +"%T")

#### pause function
function pause(){
	read -r -e -p "$show_info Press enter to continue..."
}

#### Dependencies check

function checkdependencies(){

if [[ -e /tmp/rpiv3tweak ]]; then
	echo "$show_info Checking dependencies: $show_ok"
else
	echo "dependencies_OK" > /tmp/rpiv3tweak
	echo "$show_execute Checking dependencies..."

	#### check if xterm installation exists
	if command -v xterm > /dev/null; then
		echo "$show_ok [xterm]:$WHITE installation found..."
	else
		echo "$show_warning: This script requires xterm to work"
		echo "$show_execute Downloading from network..."
		apt-get install -y xterm
	fi
	####

	#### check if vcgencmd installation exists
	if command -v vcgencmd > /dev/null; then
		echo "$show_ok [vcgencmd]:$WHITE installation found..."
	else
		echo "$show_warning: This script requires vcgencmd to work"
		echo "$show_execute Downloading from network..."
		apt-get update && apt-get upgrade && apt-get dist-upgrade
	fi
	###
	echo "$show_info All dependencies ok..."
fi
}

### Check Frequency, Temp, Voltage, Governor
function freqtempvolt() {

	function mhz_convert() {
	    #let value=$1/1000
	    #echo "$value"
	    echo $(( $1 / 1000 ))
	}

	function overvoltdecimals() {
	    #let overvolts=${1#*.}-20
	    #echo "$overvolts"
	    echo $(( ${1#*.} - 20 ))
	}

	temp=$(vcgencmd measure_temp)
	temp=${temp:5:4}

	volts=$(vcgencmd measure_volts)
	volts=${volts:5:4}

	if [[ $volts != "1.20" ]]; then
	    overvolts=$(overvoltdecimals "$volts")
	fi

	### VARS
	minFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
	minFreq=$(mhz_convert "$minFreq")
	maxFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
	maxFreq=$(mhz_convert "$maxFreq")
	freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
	freq=$(mhz_convert "$freq")
	governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
	transitionlatency=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency)
	###

	if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) == ondemand ]];
	then
		### VARS
		samplingrate=$(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)
		upthreshold=$(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)
		###

		echo "+------------------------------+"
		echo "|          CPU Details         |"
		echo "+------------------------------+"
		echo "Temperature:        $temp C"

		if [[ $volts == "1.20" ]]; then
			echo "Voltage:            $volts V"
		else
			echo -n "Voltage:            $volts V"
			[ "$overvolts" ] && echo " (+0.$overvolts overvolt)" || echo -e "\\n"
		fi

		echo "Min speed:          $minFreq MHz"
		echo "Max speed:          $maxFreq MHz"
		echo "Current speed:      $freq MHz"
		echo "Governor:           $governor"
		echo "Sampling rate:      $samplingrate"
		echo "Up threshold:       $upthreshold"
		echo "Transition latency: $transitionlatency"
		echo "+------------------------------+"
	else
		echo "+------------------------------+"
		echo "|          CPU Details         |"
		echo "+------------------------------+"
		echo "Temperature:        $temp C"

		if [[ $volts == "1.20" ]]; then
			echo "Voltage:            $volts V"
		else
			echo -n "Voltage:            $volts V"
			[ "$overvolts" ] && echo " (+0.$overvolts overvolt)" || echo -e "\\n"
		fi

		echo "Min speed:          $minFreq MHz"
		echo "Max speed:          $maxFreq MHz"
		echo "Current speed:      $freq MHz"
		echo "Governor:           $governor"
		echo "Transition latency: $transitionlatency"
		echo "+------------------------------+"
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

echo -e "\\n$show_info Current CPU governor is:$GREEN $current_governor $STAND"
echo "$show_info Affected cpus:$GREEN $affected_cpus $STAND"
echo "$show_info Available CPU governors:$RED $available_governors $STAND"
read -r -e -p "$show_input Enter desired governor (x to cancel): " ch_governor

if [[ $ch_governor == "x" ]];
then
	echo "$show_execute Going back to main menu." && sleep 1
else
	sudo sh -c "echo $ch_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
	echo -e "$show_info Governor changed to:$RED $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)\\n${STAND}"

	if [[ $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) == ondemand ]];
	then
		echo "Ondemand governor set. You can change sampling_rate and up_threshold for better performance."
		echo "Current sampling_rate=$GREEN $(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)${STAND}"

		echo "According to Kernel Documentation, sampling_rate should get adjusted considering the transition latency."
		echo "The default model looks like this: cpuinfo_transition_latency * 1000 / 1000 = sampling_rate"

		echo "The next operation will do this for you. For example, we can choose 750"
		read -r -e -p "$show_input Enter value: " sampling_rate_value
		sudo sh -c "echo $(($(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency) * sampling_rate_value / 1000)) > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate"
		echo "sampling_rate changed to:$RED $(cat /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate)${STAND}"

		echo -e "Current up_threshold=$GREEN $(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)\\n${STAND}"
		read -r -e -p "$show_input Enter new up_threshold value: " up_threshold
		sudo sh -c "echo $up_threshold > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold"
		echo -e "up_threshold changed to:$RED $(cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold)\\n${STAND}"
		pause
	else
		pause
	fi
fi
}

### Overclocking settings
function rpioverclock() {

	read -r -e -p "$show_input Write$GREEN overclock$STAND to continue or$RED x$STAND to cancel: " oc_accept

	if [[ $oc_accept == overclock ]];
	then
		echo "$show_execute Creating backup for config.txt in /boot"
		echo "$show_info You will have an option to post-edit/review your config.txt and add personal settings before restarting."
	sleep 1
		sudo cp /boot/config.txt /boot/config.txt.rpiv3tweak_backup
		echo "hdmi_force_hotplug=1 #set by RPiv3Tweak
$(if grep -aq "Raspberry Pi 3 Model B Plus" /proc/device-tree/model; then echo "arm_freq=1500        #set by RPiv3Tweak"; elif grep -aq "Raspberry Pi 3 Model B" /proc/device-tree/model; then echo "arm_freq=1300        #set by RPiv3Tweak"; fi)
core_freq=500        #set by RPiv3Tweak
sdram_freq=500       #set by RPiv3Tweak
over_voltage=6       #set by RPiv3Tweak
boot_delay=1         #set by RPiv3Tweak" >> /boot/config.txt

		echo "$show_ok Mods written."
		echo "$show_info Please review mods..." && sleep 1
		nano /boot/config.txt
		echo -e "\\n$show_info All $show_ok"
		pause
	else
		echo -e "\\n$show_info Going back to main menu." && sleep 1
	fi
}
###


###
function change_swap() {

	get_current_swap=$(grep "CONF_SWAPSIZE=" /etc/dphys-swapfile | cut -d '=' -f2)
	echo -e "\\n::: SWAP SIZE CHANGE :::\\n"

	function swap_change() {

		read -r -e -p "$show_input Would you like to change the SWAP size? (y or n): " read_swap_change

		if [[ $read_swap_change == y ]]; then

			read -r -e -p "$show_input Enter size (recommended size is 2 * current RAM size): " read_swap_size

			if [[ $read_swap_size =~ ^[0-9][0-9][0-9][0-9]$ ]]; then

				echo "$show_execute Setting SWAP size to ${GREEN}$read_swap_size"
				if sed -i -- "s/CONF_SWAPSIZE=$get_current_swap/CONF_SWAPSIZE=$read_swap_size/g" /etc/dphys-swapfile; then echo "$show_info SWAP size changed successfully!"; else "$show_error Couldn't change SWAP size!"; fi
				if dphys-swapfile swapoff; then echo "$show_execute Stopping SWAP...$show_ok"; else echo "$show_error Couldn't stop SWAP..."; fi
				if dphys-swapfile setup; then echo "$show_execute Setting new SWAP...$show_ok"; else echo "$show_error Couldn't set up new SWAP..."; fi
				if dphys-swapfile swapon; then echo "$show_execute Starting new SWAP...$show_ok"; else echo "$show_error Couldn't start new SWAP..."; fi
			else
				echo "$show_error Wrong size entered...try again"
			fi

		elif [[ $read_swap_change == n ]]; then

			echo "$show_info We won't change SWAP.."

		elif [[ $read_swap_change == * ]]; then

			echo "$show_error Wrong option. Available options are y or n." && swap_change
		fi
	}
	swap_change
}
###

### Raspiv3CPUtweak CHANGELOG
function raspitweakchangelog(){

	### VARS
	checknet=$(ping -q -w 1 -c 1 google.com 2>&1 > /dev/null && echo Internet OK.)
	###

	if [[ "$checknet" == "Internet OK." ]]; then
	### VARS
	changelog=$(curl --silent --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36" -q https://raw.githubusercontent.com/cbusuioceanu/Raspberry-Pi-v3-Tweaker/master/changelog.txt)
	last_version=$(curl --silent --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36" -q https://raw.githubusercontent.com/cbusuioceanu/Raspberry-Pi-v3-Tweaker/master/version.txt)
	###

		if [[ $last_version > $unixtime ]]; then
			echo -e "\\n$show_info Checking for update: $REDbg${WHITE}New version available!\\n$STAND"
			echo "${YELLOW}Changelog:${MAGENTA}
$changelog $STAND"
			function update() {
				read -r -e -p "$show_input Press y to update now via update.sh script (y or n): " option
				case $option in
			  		y) bash update.sh;;
					n) echo "$show_info Ok, we'll update later." ;;
     					*) echo "$show_error $option is not a valid option..."; update ;;
			    	esac
			}
			update
		else
			echo -e "\\n$show_info Checking for update:${YELLOW} You already have the latest version!"
		fi
	else
		echo -e "\\n$show_error No Internet connection." && sleep 1
	fi
}

#### Exit Raspiv3CPUtweak
function expit_tweaker () {
  echo "Bye!" && exit 0
}

###
mainmenu(){
#### Infinite Loop To Show Menu Until Exit
#trap '{ echo "CTRL C Detected. Closing script..."; exit 0; }' SIGINT

while :
do
echo "${YELLOW}+------------------------------+"
echo "| Raspberry Pi 3 Tweaker       |"
echo "| Script version: $version   |"
echo "+------------------------------+$STAND${WHITE}"
echo "+------------------------------+"
echo "| 1. Show CPU details          |"
echo "| 2. Change CPU Govenor        |"
echo "| 3. Overclock                 |"
echo "| 4. Change SWAP               |"
echo "| 5. Updates                   |"
echo "| 6. EXIT                      |"
echo "+------------------------------+${STAND}"
read -r -e -p "$show_input Choose an option: " menuoption

case $menuoption in
1) freqtempvolt ;;
2) changegovernor ;;
3) rpioverclock ;;
4) change_swap ;;
5) raspitweakchangelog ;;
6|q) expit_tweaker ;;
*) echo "'$menuoption' Is not a valid option!" && sleep 1;;
esac
done
}
#End

checkdependencies
mainmenu
