#!/bin/bash

#Remove RHOST selection in sys.argv
#Get remote ip from sourceHost

NUp=false
SSHLocalUp=false
SSHRemoteUP=false
SSHConUp=false

OK="\e[32m[+]\e[0m"
NOK="\e[31m[X]\e[0m"
NTF="\e[94m[*]\e[0m"

remoteAddr=
sourceHost="109.160.87.6" #Default value 
sourcePath=""

while getopts h arg
do
   case $arg in
      h) #Print help guide
         echo "#####" #Add usage
         ;;
      s) #Set source  host of dynimic ip discovery
         sourceHost = $OPTARG
         ;;
   esac
done

ssh_reverse() {
   if ssh_remote_port_is_open $remoteAddr; then
      SSHRemoteUP=true
      echo -e "${OK}SSH Remote Addres: port 22 open"
      #while ! sshpass -p "57289" ssh -T -o StrictHostKeyChecking=no -R $1:localhost:22 $2@$3
      #do
      #   echo -e "${NOK}Can't create tunnel. Check host availability"
      #   SSHConUp=false
      #done
      autossh -M 20000 -N -i /home/tofm/.ssh/id_rsa -R $1:localhost:22 $2@$3
      SSHConUp=true
   else
      echo -e "${NOK}SSH Remote Addres: port 22 is not open"
   fi
}

ssh_remote_port_is_open() {
   nc -z ${1:?hostname} 22 > /dev/null;
}

ssh_local_port_is_open(){
   if [[ $(systemctl is-active ssh | grep "active") = "active" ]]; then
      echo -e "${OK}SSH service up"
      SSHLocalUp=true
   else
      echo -e "${NOK}SSH sevice down"
      SSHLocal=false
   fi
}

set_dynamic_rhost() {
   #Download from source and red it
   #Then set the variable


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
      fi
   done

   if $NUp && $SSHLocalUp && [ $SSHConUp ]; then
      echo -e "${NTF}Attempting SSH tunnel..."
      ssh_reverse $1 $2 $3
   else
      echo -e "${NOK}Check network or local ssh configuration"
   fi
done
