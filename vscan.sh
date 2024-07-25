#!/bin/sh

echo '\n'
echo '                   ___           ___           ___           ___                    '
echo '     ___          /  /\         /  /\         /  /\         /  /\                   '
echo '    /  /\        /  /::\       /  /::\       /  /::\       /  /::|                  '
echo '   /  /:/       /__/:/\:\     /  /:/\:\     /  /:/\:\     /  /:|:|                  '
echo '  /  /:/       _\_ \:\ \:\   /  /:/  \:\   /  /::\ \:\   /  /:/|:|__                '
echo ' /__/:/  ___  /__/\ \:\ \:\ /__/:/ \  \:\ /__/:/\:\_\:\ /__/:/ |:| /\               '
echo ' |  |:| /  /\ \  \:\ \:\_\/ \  \:\  \__\/ \__\/  \:\/:/ \__\/  |:|/:/               '
echo ' |  |:|/  /:/  \  \:\_\:\    \  \:\            \__\::/      |  |:/:/                '
echo ' |__|:|__/:/    \  \:\/:/     \  \:\           /  /:/       |__|::/                 '
echo '  \__\::::/      \  \::/       \  \:\         /__/:/        /__/:/                  '
echo '      ~~~~        \__\/         \__\/         \__\/         \__\/                   '
echo '                                                                                    '
echo '                                                                                    '
echo ' VScan - a tool that automates the nmap vulnerability scanner using nse scripts     '
echo ' Ver. 1.0                                                                           '
echo ' written by: @xvass                                                                 '
echo '                                                                                    '
echo ' usage: ./vscan.sh [ipadress_range] [protocol] [port] <Pn (optional)>               '
echo '\n'


protocol="$2"
port="$3"
addr_range="$1"
option="$4"

if [ ! -f $addr_range ];then

	if [ "$option" = 'Pn' ];then
	       ip_for_ping=`echo $addr_range | sed 's/\(.*\)\-\(.*\)/\1/'`
	       online=`ping -c 1 $ip_for_ping | grep "bytes" | awk -F" " -v var=$protocol '/bytes/ { print "online" }'`
            	if [ "$online" != "online" ]; then
        	        echo " "
                	echo "Offline or icmp req blocking... check connection"
                	exit 1
      		 fi
	fi
fi


if [ $# != 4 ];then
if [ $# != 3 ];then
if [ $# -eq 1 ];then

	if [ $# -eq 2 ];then

		if [ $# != 3 ]; then
			echo 'usage: ./vscan.sh [ipadress_range] [protocol] [port] <Pn (optional)>'
			exit 1
		fi
	else
		echo 'usage: ./vscan.sh [ipadress_range] [protocol] [port] <Pn (optional)>'
		exit 1
	fi
else
	echo " "
	echo 'usage: ./vscan.sh [ipadress_range] [protocol] [port] <Pn (optional)>'
	exit 1
fi
fi
fi

if [ "$port" != "NaN" ]; then
	if [ ! -f $addr_range ]; then
		nmap -n -v -T5 -Pn $addr_range | awk -F" " -v ps=$port '{ if ($4==ps"/tcp") print $6 }' | sort -n -u -k1 > ips.txt
	else
 
		nmap -n -v -T5 -Pn -iL $addr_range | awk -F" " -v ps=$port '{ if ($4==ps"/tcp") print $6 }' | sort -u > ips.txt
	fi
else
	if [ ! -f $addr_range ]; then
	 	nmap -n -v -T5 -Pn $addr_range | awk -F" " '{ if ($1=="Discovered") print $6 }' | sort -u -n -k1 > ips.txt
	else
		nmap -n -v -T5 -Pn -iL $addr_range | awk -F" " '{ if ($1=="Discovered") print $6 }' | sort -u > ips.txt
	fi
fi

ls /usr/share/nmap/scripts | grep "$protocol-.*" > file.txt

touch scanned.txt

while read line; do

	echo "#--------------------------------#"
	echo "\033[31m$line\033[0m"
	echo "#--------------------------------#" '\n'

	while read ip_address; do

		echo "\033[36m[*] NSE script: $line - Scanning for IP: $ip_address\033[0m"
        	echo "\n"
		if [ "$port" != "NaN" ];then
                	echo "==========================================================================="
                	nmap -n --script=/usr/share/nmap/scripts/$line $ip_address -p "$port" | sed '/Starting/d' | sed '/Nmap done/d' | sed '/Nmap scan/d'
                	echo "===========================================================================" '\n'
                else
                	echo "==========================================================================="
                	nmap -n --script=/usr/share/nmap/scripts/$line $ip_address | sed '/Starting/d' | sed '/Nmap done/d' | sed '/Nmap scan/d'
                	echo "===========================================================================" '\n'
                fi

		vul="not vuln"

		if [ "$port" != "NaN" ];then
			vul=`nmap -n --script=/usr/share/nmap/scripts/$line $ip_address -p "$port" | awk -F" " '/VULNERABLE/ || /Vulnerable/ { print $2 }' | sed 's/State://' | sed 's/\(^.*\):/\1/'`
		else
			vul=`nmap -n --script=/usr/share/nmap/scripts/$line $ip_address | awk -F" " '/VULNERABLE/ || /Vulnerable/ { print $2 }' | sed 's/State://' | sed 's/\(^.*\):/\1/'`
		fi

		if [ $vul = "VULNERABLE" -o $vul = "Vulnerable" ]; then

			echo "\033[33m$ip_address is Vulnerable to $line\33[0m  \033[31mPlease check at /home/vulnerabilities_enumeration/"$protocol"_vulnerabilities/"$protocol"_vulnerabilities.txt\033[0m" '\n'
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
