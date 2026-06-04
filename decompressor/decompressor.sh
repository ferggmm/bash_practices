#!/bin/bash

function ctrl_c(){
  echo -e "\n\n_!_ Exit...\n"  
  exit 1
}

#Ctrl + c
trap ctrl_c INT
#sleep 10

ori="data.gz"
nw="$(7z l data.gz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"

7z x $ori &>/dev/null

while [ $nw ]; do
  echo -e "\n_+_ New decompressed file: $nw"
  7z x $nw &>/dev/null
  nw="$(7z l $nw 2>/dev/null | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"
done
