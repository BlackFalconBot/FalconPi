#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"
 
    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}

trap "trap_ctrlc" 2

setupTools(){
echo -e "${GREEN}[+] Setting things up.${RESET}"
#   sudo apt update -y
#   sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt clean
    sudo apt install -y gcc g++ make libpcap-dev xsltproc
    sudo apt install python3-pip -y 
    sudo apt install php -y 
    sudo apt install python-pip -y   
    sudo pip install ansi2html
    sudo apt install ccze -y
    sudo apt-get install nmap -y
    sudo pip install python-libnmap
    sudo pip install XlsxWriter
    wget https://raw.githubusercontent.com/mrschyte/nmap-converter/master/nmap-converter.py
    chmod +x nmap-converter.py
  	FILE=directory-list.zip
  	if [ -f "$FILE" ]; then
    	echo "Directory Listing Zip file found"
	Done
	else
	echo "$FILE does not exist"
	echo "Downloading directory-listing.zip"
	wget https://github.com/r12w4n/AVIATO-CLI/raw/master/directory-list.zip
	echo "Done"
	fi


	FILE2=snmp-community.txt
        if [ -f "$FILE2" ]; then
        echo "SNMP Community String List Found"
        Done
        else
        echo "$FILE2 does not exist"
        echo "Downloading SNMP Community String List Found"
        wget https://raw.githubusercontent.com/r12w4n/AVIATO-CLI/master/snmp-community.txt
        echo "Done"
        fi
   
 
   #wget -P /usr/share/nmap/scripts/ https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
    #cd /usr/share/nmap/scripts/ && git clone https://github.com/scipag/vulscan.git
    vulners="/usr/share/nmap/scripts/vulners.nse"
	if [ ! -f "$vulners" ]
	then
		echo "${GREEN}Downloading vulners${RESET}"
		wget -P /usr/share/nmap/scripts/ https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse
	fi

    	vulscan="/usr/share/nmap/scripts/vulscan"

	if [ ! -d "$vulscan" ]
	then
		echo "${GREEN}Downloading vulscan${RESET}"
		cd /usr/share/nmap/scripts/ && git clone https://github.com/scipag/vulscan.git
	fi
}

setupTools
nmap --script-updatedb
