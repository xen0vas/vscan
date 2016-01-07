#!/bin/sh

  ##
##################################
# Vulnerability scanner          # ---- - --- (#######|>
##################################
## @xvass ####
##	  ####
###########
#  #  #
#     #
#######


protocol="$2"
port="$3"
addr_range="$1"
option="$4"

if [ "$option" = 'Pn' ];then

       ip_for_ping=`echo $addr_range | sed 's/\(.*\)\-\(.*\)/\1/'`
       online=`ping -c 1 $ip_for_ping | grep "bytes" | awk -F" " -v var=$protocol '/bytes/ { print "online" }'`

       if [ "$online" != "online" ]; then
                echo " "
                echo "Offline or icmp req blocking... check connection"
                exit 1
       fi
fi

if [ $# != 4 ];then
if [ $# != 3 ];then
if [ $# -eq 1 ];then

	if [ $# -eq 2 ];then

		if [ $# != 3 ]; then
			echo "[Usage:] ./vuln_scan.sh <ipadress_range> <protocol> <port>"
			exit 1
		fi
	else
		echo "[Usage:] ./vuln_scan.sh <ipadress_range> <protocol> <port>"
		exit 1
	fi
else
	echo " "
	echo "[Usage:] ./vuln_scan.sh <ipadress_range> <protocol> <port>"
	exit 1
fi
fi
fi

if [ "$port" != "NaN" ]; then
	nmap -v -T5 -Pn $addr_range | awk -F" " -v ps=$port '{ if ($4==ps"/tcp") print $6 }' | sort -n > ips.txt
else
	 nmap -v -T5 -Pn $addr_range | awk -F" " '{ if ($1=="Discovered") print $6 }' | sort -n > ips.txt
fi

ls /usr/share/nmap/scripts | grep "$protocol-.*" > file.txt

echo '\n'
echo "####################################"
echo "#     Vulnerability scanner        #" 
echo "####################################"
echo '\n'
touch scanned.txt
while read line; do

	echo "**************************"
	echo "\033[31m$line\033[0m"
	echo "**************************" '\n'

	while read ip_address; do

		echo "\033[36m[*] NSE script: $line - Scanning for IP: $ip_address\033[0m"
        	echo "\n"
		if [ "$port" != "NaN" ];then
                echo "==========================================================================="
                nmap --script=/usr/share/nmap/scripts/$line $ip_address -p "$port" | sed '/Starting/d' | sed '/Nmap done/d' | sed '/Nmap scan/d'
                echo "===========================================================================" '\n'
                else
                echo "==========================================================================="
                nmap --script=/usr/share/nmap/scripts/$line $ip_address | sed '/Starting/d' | sed '/Nmap done/d' | sed '/Nmap scan/d'
                echo "===========================================================================" '\n'
                fi
		vul="not vuln"
		if [ "$port" != "NaN" ];then
			
			vul=`nmap --script=/usr/share/nmap/scripts/$line $ip_address -p "$port" | awk -F" " '/VULNERABLE/ || /Vulnerable/ { print $2 }' | sed 's/State://' | sed 's/\(^.*\):/\1/'`
		else
		
			vul=`nmap --script=/usr/share/nmap/scripts/$line $ip_address | awk -F" " '/VULNERABLE/ || /Vulnerable/ { print $2 }' | sed 's/State://' | sed 's/\(^.*\):/\1/'`
		fi
		if [ $vul = "VULNERABLE" -o $vul = "Vulnerable" ]; then
			echo "\033[33m$ip_address is Vulnerable to $line\33[0m  \033[31mPlease check at /home/vulnerabilities_enumeration/"$protocol"_vulnerabilities/"$protocol"_vulnerabilities/"$protocol"_vulnerabilities.txt\033[0m" '\n'
			echo "===========================================================================" '\n'

		if [ ! -d /home/vulnerabilities_enumeration ]; then
			mkdir -p vulnerabilities_enumeration
		fi
	  	if [ ! -d /home/vulnerabilities_enumeration/"$protocol"_vulnerabilities ]; then
	        	 mkdir -p /home/vulnerabilities_enumeration/"$protocol"_vulnerabilities
	  	fi
		echo "$ip_address is Vulnerable to $line" '\n\n' >> /home/vulnerabilities_enumeration/"$protocol"_vulnerabilities/"$protocol"_vulnerabilities.txt
		fi 2>/dev/null
		sleep 3
	done < ips.txt
	sleep 3
done < file.txt
echo "Bye ! " '\n'
rm ips.txt
rm file.txt
rm scanned.txt


