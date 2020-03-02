#!/bin/bash
#title:         civilized.sh
#description:   Configuration Script
#author:        R12W4N
#==============================================================================
[ "$DEBUG" == 'true' ] && set -x
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
BLUE=`tput setaf 4`

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"
 
    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}
trap "trap_ctrlc" 2 

function setup()
{
	read -p "${RED}Enter FalconPool Unit Name : ${RESET}" FalconName
	read -p "${RED}Enter FalconPool Unit Password : ${RESET}" Password
	read -p "${RED}Enter Falcon Unique ID :${RESET} " FUID
	if ! [[ "$FUID" =~ ^[0-9]+$ ]]
    		then
        		echo "Sorry integers only"
			setup
	fi
}

function adduser(){
echo "${GREEN}Adding User $FalconName ${RESET}"
/bin/bash ./modules/adduser.sh -a add $FalconName $Password
echo "${GREEN}Adding User $FalconName to Sudoers List ${RESET}"
usermod -aG sudo $FalconName
echo "${GREEN}Configuring SSH key based secure authentication ${RESET}"
echo "${GREEN}Generating SSH Keys ${RESET}"
ssh-keygen
echo "${GREEN}RSA Key Generated Successfully${RESET}"
read -p "${RED}Enter CnC User  : ${RESET}" cncuser
read -p "${RED}Enter Cnc Server IP : ${RESET}" cncip
ssh-copy-id $cncuser@$cncip
echo "${GREEN}DONE ${RESET}"
}

function installer(){
	echo "${GREEN}Updating${RESET}"
	apt update -y
	apt --fix-broken install -y
	
	if [[ ! -x /usr/bin/autossh ]] ; then
  		read -p "${GREEN}You will need autossh! Shall I invoke 'apt install autossh' for you${RESET} (Y/n)? "
  	if [ "$REPLY" != "n" ]; then
    		apt install autossh -y
  	fi
	fi
}

function autossh(){
echo "${GREEN}Setting up rc-local.service ${RESET}"
cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target

EOF

echo "${GREEN}Setting up rc.local${RESET}"
touch /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local

read -p "${RED}Enter Monitoring Port : ${RESET}" mp
echo "${GREEN}Setting up autossh ${RESET}"
cat > /etc/rc.local << EOF
#!/bin/bash -e
autossh -M $mp -fN -o "PubkeyAuthentication=yes" -o "StrictHostKeyChecking=false" -o "PasswordAuthentication=no" -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" -R $FUID:localhost:22 -i /root/.ssh/id_rsa $cncuser@$cncip &
exit 0
EOF


sudo systemctl start rc-local.service
sudo systemctl status --no-pager rc-local.service
echo "${GREEN}ssh $FalconName@$cncip -p $FUID ${RESET}"
}

setup
adduser
installer
autossh
