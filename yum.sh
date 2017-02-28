#!/bin/bash
clear;
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
		cat $last_log | awk '{print $1,$2}' | uniq | tail -1; 	
fi;

### yum cron last run

echo -e "\nLast yum update cron run :"

yum_cron_last_run=`mktemp`

grep -i yum /var/log/cron | awk '{print $1,$2,$6,$7}' | uniq | tail -2 > $yum_cron_last_run

if [[ ! -s $yum_cron_last_run ]]; then
	echo "Nothing Returned"
else
	cat $yum_cron_last_run
rm -rf $yum_cron_last_run
fi


echo -e "\nKernel updates :"
echo "================="

## Checking Kernel installed, lastest kernel installed and latest_kernel_available.
latest_kernel_installed=$(rpm -qa | grep -i ^kernel-[0-9]| sort -rn | grep el[0-9] | head -1 | cut -d- -f2,3,4)
kernel_loaded=$(uname -r)
latest_kernel_available=$(yum check-update kernel --disableexcludes=all 2>&1 | grep ^kernel  | awk '{print $2}')

## is the loaded kernel the latest installed one ??
if [[ $latest_kernel_installed == $kernel_loaded ]]; then 
		echo -n "Server is loaded into the latest kernel installed : "; 
		loaded_latest_kernel_installed="yes"
		echo $kernel_loaded; 
	else 
		echo "Lastest kernel installed is : $latest_kernel_installed" ; 
		echo "BUT Server is on the kernel $kernel_loaded"; 
		loaded_latest_kernel_installed="no"
fi

## 
if [[ -z $latest_kernel_available ]]  && [[ $loaded_latest_kernel_installed == "yes" ]]; then
	echo -e "\nServer is up-to-date with kernel"
	echo -e "And is Loaded into the Latest Kernel"

elif [[ -z $latest_kernel_available ]] && [[ $loaded_latest_kernel_installed == "no" ]]; then
	echo -e "Server has latest Kernel"
	echo -e "But needs reboot to boot into the new kernel $latest_kernel_installed" 

else 
	echo -e "\nHowever, Kernel will need update.\nLastest kenrel available is : $new_kernel" ; 
	echo "Server is on the kernel: $kernel_loaded"; 
fi;

