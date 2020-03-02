#!/bin/bash
#title:         PiMap.sh
#description:   Automated Script to Scan Vulnerability in Network
#author:        R12W4N
#==============================================================================
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
BLUE=`tput setaf 4`
function trap_ctrlc ()
{
    echo "Ctrl-C caught...performing clean up"
 
    echo "Doing cleanup"
    trap "kill 0" EXIT
    exit 2
}

function progressBar()
{
    echo -ne "Please wait\n"
    while true
    do
        echo -n "${BLUE}#"
        sleep 2
    done
}

banner(){
echo -e "${GREEN}

 █████╗ ██╗   ██╗██╗ █████╗ ████████╗ ██████╗ 
██╔══██╗██║   ██║██║██╔══██╗╚══██╔══╝██╔═══██╗
███████║██║   ██║██║███████║   ██║   ██║   ██║
██╔══██║╚██╗ ██╔╝██║██╔══██║   ██║   ██║   ██║
██║  ██║ ╚████╔╝ ██║██║  ██║   ██║   ╚██████╔╝
╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝                                           	    
 _           _ _              ()            _            ____  
//\utomated  \\/ulnerability  []ntegrated  //\ssessment   L| ool ${RESET}"                                                               

}
trap "trap_ctrlc" 2 


#Menu options
options[0]="${GREEN}Localhost Discovery + Basic Recon${RESET}"
options[1]="${GREEN}Vulnerability Scan${RESET}"
options[2]="${GREEN}Advance Vulnerability Scan${RESET}"
options[3]="${GREEN}EternalBlue Doublepulsar${RESET}"
options[4]="${GREEN}Anonymous FTP Scan${RESET}"
options[5]="${GREEN}Router / Wireless Web Login${RESET}"
options[6]="${GREEN}SMTP and SAMBA Enumeration${RESET}"
options[7]="${GREEN}HTTP Enumeration${RESET}"
options[8]="${GREEN}VNC Vuln + SNMP Brute${RESET}"

reportdir(){
    echo -e "\n${RED}[+] Creating results directory.${RESET}"
    mkdir -p $name-aviato-reports && cd $name-aviato-reports
    mkdir HTML-Reports raw && mkdir raw/http raw/vnc

}

lhd_scan(){
	    
        echo -e "\n${GREEN}[+]Running Localhost Discovery ${RESET}"
        nmap -sP -oG grepable-$name $iprange
        cat grepable-$name | grep Up | cut -d ' ' -f 2 | sort -u > $name-livehost.txt
        cat $name-livehost.txt
        echo -e "\n${GREEN}[+]Logging Live Host Done ${RESET}"
	
}

basic_scan(){
	    
        echo -e "\n${GREEN}Basic Enumeration ${RESET}"
        #Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
	nmap -A -oA basic_scan_$name $iprange | ccze -A | ansi2html > raw/raw_basic_scan_$name.html
        echo -e "\n${GREEN}Main Scan Done ${RESET}"
	sleep 20
	xsltproc -o HTML-Reports/basic_scan_$name.html ../nmap-bootstrap.xsl basic_scan_$name.xml
	sleep 20
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1
	echo -e "\n${GREEN}Main Scan Report Generated ${RESET}"

}

vulners_cve(){
	    
        echo -e "\n${GREEN}Scanning for vulnerabilities CVE in live host ${BLUE}"
	#Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
        nmap -Pn -oA vulners_scan_$name -sV --script vulners --script-args mincvss=7.0 $iprange | ccze -A | ansi2html > raw/raw_vulners_$name.html
        echo -e "\n${GREEN}Vulnerability Scanning Done ${reset}"
	sleep 20
	xsltproc -o HTML-Reports/vulners_scan_$name.html ../nmap-bootstrap.xsl vulners_scan_$name.xml
	sleep 20
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1
        echo -e "\n${GREEN} Report Generated ${RESET}"

        #nmap -Pn -oA Dvuln_scan_$name -sV $iprange --script vuln | ccze -A | ansi2html > Dvuln_scan_$name.html
	#xsltproc -o Dvuln_scan_$name.html ../nmap-bootstrap.xsl Dvuln_scan_$name.xml

}

adv_scan(){
	echo -e "\n${GREEN}Advance Vulnerabilty Scan Started ${BLUE}"
        #Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
	nmap -oA advance_vuln_$name -sV $iprange --script=vulscan/vulscan.nse --script-args vulscandb=exploitdb.csv | ccze -A | ansi2html > raw/raw_advance-vuln.html
	echo -e "\n${GREEN}Advance Vulnerabilty Scan Completed ${BLUE}"
	sleep 40
	xsltproc -o HTML-Reports/advance_vuln_$name.html ../nmap-bootstrap.xsl advance_vuln_$name.xml
	sleep 40
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1
	echo -e "\n${GREEN} Report Generated ${RESET}"

}

MS17_010(){
	echo -e "\n${GREEN}Eternalblue Doublepulsar Scan Initiated ${BLUE}"
  	#Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
	nmap -oA Eternal_MS17_010_$name -Pn -p445 --open --max-hostgroup 3 --script smb-vuln-ms17-010 $iprange | ccze -A | ansi2html > raw/raw_ms17_010.html
        echo -e "\n${GREEN}Eternalblue Doublepulsar Scan Completed ${RESET}"
	sleep 20
	xsltproc -o HTML-Reports/Eternal_MS17_010_$name.html ../nmap-bootstrap.xsl Eternal_MS17_010_$name.xml
	sleep 20
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1
        echo -e "\n${GREEN}Report Generated ${RESET}"

}

anonftp(){
           # Anonymous FTP
           echo -e"\n${GREEN}Scanning for Anonymous FTP ${RESET}"
	   #Start in background
	   progressBar &
	   #Save PID progressBar to variable
	   MYSELF=$!
	   nmap -oA AnonymousFTP_$name -v -p 21 --script=ftp-anon.nse $iprange | ccze -A | ansi2html > raw/raw_anonftp.html
           sleep 10
           echo -e "\n${GREEN}Anonymous FTP Scan Completed ${RESET}"
	   sleep 20
	   xsltproc -o HTML-Reports/AnonymousFTP_$name.html ../nmap-bootstrap.xsl AnonymousFTP_$name.xml
	   sleep 20
	   #kill progressBar function
	   kill $MYSELF > /dev/null 2>&1
	   echo -e "\n${GREEN}Report Generated ${RESET}"
 
}

routerweblogin(){
        echo -e "\n${GREEN}Scanning for any Router Web Portal${RESET}"
	#Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
        #Router / Wireless Web Login
        nmap -oA RouterWebLogin_$name -sS -sV -vv -n -Pn -T5 $iprange -p80 -oG - | grep 'open' | grep -v 'tcpwrapped' | ccze -A | ansi2html > raw/raw_RouterWebLogin.html
        echo -e "\n${GREEN}Scan Completed${RESET}"
	sleep 20
	xsltproc -o HTML-Reports/RouterWebLogin_$name.html ../nmap-bootstrap.xsl RouterWebLogin_$name.xml
	sleep 20
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1
	echo -e "\n${GREEN} Report Generated ${RESET}"

}

smtpnsmb(){
    # SMTP and Samba Vulnerabilities
        #Start in background
	progressBar &
	#Save PID progressBar to variable
	MYSELF=$!
	nmap --script smtp-vuln-* -p 25  $iprange > raw/smtp.txt
        nmap --script smb-vuln-* -p 445 $iprange > raw/smb-vuln.txt
        nmap --script ftp-vuln-* -p 21 $iprange > raw/ftpvuln.txt
        nmap --script smb-enum-shares.nse -p445 $iprange > raw/smbshare.txt 
        nmap --script smb-os-discovery.nse -p445 $iprange > raw/smbosdiscovery.txt
	#kill progressBar function
	kill $MYSELF > /dev/null 2>&1

}

http_enum(){
        # HTTP Enum
        nmap --script http-enum $iprange > httpenum.txt
        # HTTP Title
        nmap --script http-title -sV -p80,443 $iprange > raw/http/httptitle.txt
        # HTTP Vulnreability CVE2010-2861
        nmap -v -p80,443 --script http-vuln-cve2010-2861 $iprange> raw/http/httpvuln.txt

}

vnc_scan(){
        # VNC Title
        nmap -sV --script=vnc-title $iprange > raw/vnc/vnctitle.txt
        # VNC Brute
        nmap --script vnc-brute -p 5900 $iprange > raw/vnc/vncbrute.txt
        # Auth RealVNC Bypass
        nmap -sV --script=realvnc-auth-bypass $iprange > raw/vnc/vncbypass.txt
}

snmp(){
	# SNMP Brute Force
	nmap -sU --sript snmp-brute $iprange --sript-args snmp-brute.communitiesdb=snmp-community.txt > raw/snmpbrute.txt
}

reporter(){
	echo "Uploading Generated Reported On Web"
	#on the way

}

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        echo "Option 1 selected"
	lhd_scan
	basic_scan
	
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
        echo "Option 2 selected"
	vulners_cve
	
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
        echo "Option 3 selected"
	adv_scan
	
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
        echo "Option 4 selected"
	MS17_010
	
    fi
    if [[ ${choices[4]} ]]; then
        #Option 5 selected
        echo "Option 5 selected"
	anonftp
    fi
    if [[ ${choices[5]} ]]; then
        #Option 6 selected
        echo "Option 6 selected"
	routerweblogin
	
    fi
    if [[ ${choices[6]} ]]; then
        #Option 7 selected
        echo "Option 7 selected"
	smtpnsmb
    fi
    if [[ ${choices[7]} ]]; then
        #Option 8 selected
        echo "Option 8 selected"
	http_enum
    fi
    if [[ ${choices[8]} ]]; then
        #Option 9 selected
        echo "Option 9 selected"
    fi
    if [[ ${choices[9]} ]]; then
        #Option 10 selected
        echo "Option 10 selected"
	vnc_scan
	snmp
    fi
    if [[ ${choices[10]} ]]; then
        #Option 11 selected
        echo "Option 11 selected"
    fi

}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Menu Options"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

#Starts from here

banner
echo "${BLUE}[+] Don't forget to run it under screen ... ${RESET}"
read -p "${RED}Enter the Project Name : ${RESET}" name
read -p "${RED}Enter IP Address/ IP Range :${RESET} " iprange

#read -p "Start Scanning ? y/n " ss
reportdir
ACTIONS

