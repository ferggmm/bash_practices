#!/bin/bash

function ctrl_c(){
    echo -e "\n\n{!} Aborting...\n"
    tput cnorm; 
    exit 1
}

#Ctr+c
trap ctrl_c SIGINT

tput civis #hide cursor

if [ $1 ]; then
  for port in $(seq 1 100); do
    (echo '' > /dev/tcp/$1/$port) 2>/dev/null && echo -e "{+} PORT: $port is open!" &
  done 
else 
  echo '\n{+} Use: $0 <ip_addres>\n'
fi
wait
#retrieve cursor
tput cnorm
exit 0

