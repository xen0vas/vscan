# vscan

vulnerability scanner tool using nmap and nse scripts into vulnerability discovery functionality

This tool puts an additional value into vulnerability scanning with nmap. 
It uses NSE scripts which can add flexibility in terms of vulnerability detection and exploitation.
Below there are some of the features that NSE scripts provide  

- Network discovery
- More sophisticated version detection
- Vulnerability detection
- Backdoor detection
- Vulnerability exploitation

```This tool uses the path /usr/share/nmap/scripts/ where the nse scripts are located in kali linux``` 
```If the tool finds a vulnerabilty it takes log which are saved in the following location /home/vulnerabilities_enumeration/http_vulnerabilities/http_vulnerabilities/http_vulnerabilities.txt```

##Usage: 

```[Usage:] ./vscan.sh <ipadress_range> <protocol> <port>```

##example:

```./vscan.sh 192.168.162.90 http 80``` 

##References :
- https://nmap.org/book/nse.html
- https://nmap.org/nsedoc/

##Screenshots:

![vuln_scan](https://cloud.githubusercontent.com/assets/12726776/12111385/820089b6-b39d-11e5-9664-ab8f4c0ae417.PNG)

###Slowloris 

![slowloris](https://cloud.githubusercontent.com/assets/12726776/12113240/28be284c-b3aa-11e5-99f6-faa19a9ba00f.PNG)
