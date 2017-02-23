#!/bin/bash
echo -e "server :" `cat /root/.rackspace/server_number` "\n"
echo "OS :" `cat /etc/redhat-release`

/etc/init.d/yum-cron status; echo
yum_exclusions=$(grep ^exclude /etc/yum.conf)
if [[ -z $yum_exclusions ]]
	then
		echo "Yum Exclusions : None"
	else
		echo "Yum Exclusions : $yum_exclusions"
fi

echo -e "\nYum updates info:"
echo "================="
last_log=$(find /var/log/ -name "yum.log*" -type f -size +30c | xargs ls -1tr | tail -1);

if [[ $last_log =~ \.gz$ ]]; 
	then 
		echo -en "$last_log\nLast Modified :"; 
		stat -c %y $last_log; 
		echo -n "Packages last updated: "; 
		zcat $last_log | awk '{print $1,2}' | uniq | tail -1; 
	else 
		echo -en "$last_log\nLast Modified :"; 
		stat -c %y $last_log; 
		echo -n "Packages last updated: "; 
		cat $last_log | awk '{print $1,2}' | uniq | tail -1; 	
fi;

echo -e "\nLast yum update run :"
grep -i yum /var/log/cron | awk '{print $1,$2,$6,$7}' | uniq | tail -2

echo -e "\nKernel updates :"
echo "================="
last_kernel_update=$(rpm -qa | grep -i ^kernel-[0-9]| sort -rn | grep el[0-9] | tail -1 | cut -d- -f2,3,4)
kernel_loaded=$(uname -r)

if [[ $last_kernel_update == $kernel_loaded ]]; 
	then 
		echo -n "Server is on the most recent kernel installed : "; 
		echo $kernel_loaded; 
	else 
		echo "Last kernel update is : $last_kernel_update" ; 
		echo "Server is on the kernel $kernel_loaded"; 
		echo "This server will need a reboot"; 
fi


new_kernel=$(yum check-update kernel --disableexcludes=all 2>&1 | grep ^kernel  | awk '{print $2}')
if [[ $last_kernel_update == $new_kernel ]]; 
	then 
		echo -e "\nServer is up-to-date"; 
	else 
		echo -e "\nHowever, Kernel will need update.\nLastest kenrel available is : $new_kernel" ; 
		echo "Server is on the kernel: $kernel_loaded"; 
fi;

