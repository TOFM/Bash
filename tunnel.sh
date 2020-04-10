#!/bin/bash

#Make local ssh up check
#Get remote ip from sourceHost

CON_TIMEOUT=30

NUp=false
SSHLocalUp=true
SSHRemoteUP=false
SSHConUp=false

#Interactive log color scheme
OK="\e[32m[+]\e[0m"
NOK="\e[31m[X]\e[0m"
NTF="\e[94m[*]\e[0m"

remoteAddr=
remoteUser="tofm" #Default
fwdPort="4444" #Default

sourceHost="109.160.87.6" #Default (syslan)
sourcePath="/var/www/" #Default

usage(){
   echo "Usage: ./tunnel.sh "
}

while getopts "hsr:pua" arg
do
   case $arg in
      h) #Print usage guide
         usage
         exit 1
         ;;
      s) #Set source host of dynimic ip discovery
         sourceHost=${OPTARG}
         ;;
      r) #Set remote addres
         remoteAddr=${OPTARG}
         ;;
      p) #Set/change the default forwarded port
         fwdPort=${OPTARG}
         ;;
      u) #Set/change login user for remote host
         remoteUser=${OPTARG}
         ;;
      :)
         echo "ERROR: Option -$OPTARG requires an argument"
         ;;
      \?)
         echo "ERROR: Invalid option -$OPTARG"
         usage
         ;;
   esac
done

ssh_remote_port_is_open() {
   nc -zv $1 22 > /dev/null
   echo ":${1}:"
}

ssh_reverse() {
   if ssh_remote_port_is_open $remoteAddr; then
      SSHRemoteUP=true
      echo -e "${OK}SSH Remote Addres: port 22 open"
      #while ! sshpass -p "57289" ssh -T -o StrictHostKeyChecking=no -R $1:localhost:22 $2@$3
      #do
      #   echo -e "${NOK}Can't create tunnel. Check host availability"
      #   SSHConUp=false
      #done
      if autossh -M 20000 -N -i /home/tofm/.ssh/id_rsa -R $1:localhost:22 $2@$3; then
         SSHConUp=true
      else
         echo -e "${NOK}Could not establish connection to remote host"
         SSHConUp=false
      fi
   else
      echo -e "${NOK}SSH Remote Addres: port 22 is not open"
   fi
}

ssh_local_port_is_open(){
   if [[ $(systemctl is-active ssh | grep "active") = "active" ]]; then
      echo -e "${OK}SSH service up"
      SSHLocalUp=true
   else
      echo -e "${NOK}SSH sevice down"
      SSHLocalUp=false
   fi
}

set_dynamic_rhost() {
   #Download from source and red it
   #Then set the variable
   echo "Placeholder"
}

echo -e "${NTF}Starting SSH Service"
systemctl start ssh

while :
do
   while [ $NUp == false ]
   do
      if ping -q -c 1 -W 1 google.com >/dev/null; then
         echo -e "${OK}IPv4 connection up"
         NUp=true
      else
         echo -e "${NOK}IPv4 connection down. Retrying..."
         NUp=false
      fi
      sleep 2s
   done

   if $NUp && $SSHLocalUp; then
      echo -e "${NTF}Attempting SSH tunnel..."
      ssh_reverse $fwdPort $remoteUser $remoteAddr
   else
      echo -e "${NOK}Check network, local ssh configuration or remote host availability ${NUp} ${SSHLocalUp}"
   fi
   sleep 1s
done
