#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c() {
  echo -e "${redColour}{+} Saliendo...${endColour}"
  tput cnorm && exit 1
}

trap ctrl_c INT

function help_panel() {
  echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Uso:${endColour} ${purpleColour}$0${endColour}\n"
  echo -e "\t${blueColour}-m)${endColour} ${grayColour}Monto de dinero${endColour}"
  echo -e "\t${blueColour}-t)${endColour} ${grayColour}Tecnica a emplear${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${grayColour})${endColour}\n"
  exit 1
}

function inverse_labrouchere() {
  declare -a my_sequence=(1 2 3 4)
  declare -i bet=0
  declare -i nm=1
  money="$1"
  echo -e "${yellowColour}{+}${endColour} ${grayColour}Tienes${endColour} ${yellowColour}$money${endColour} ${grayColour}dolares${endColour}"
  echo -ne "${yellowColour}{+}${endColour} ${grayColour}A que apuestas -> ${endColour}" && read w

  if [ "$w" == "par" ]; then 
    nm=0
  fi 
  tput civis

  while true; do 
    declare -i fl=0
    out="$(($RANDOM % 37))"
    if [ "${#my_sequence[@]}" -gt 1 ]; then 
      let bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
    elif [ "${#my_sequence[@]}" -eq 1 ]; then
      let bet=$((${my_sequence[0]}))
      let fl=1
    else 
      tput cnorm; exit 0
    fi 
    
    if [ $bet -gt $money ]; then 
      echo -e "Tienes insuficiente dinero para hacer la apuesta"

    echo -e "La secuencia actual es: [${my_sequence[@]}"]    
    echo -e "La apuesta sera de: $bet y tu dinero es de: $money"
    if [ $out -eq 0 ]; then
      echo -e "Sale 0. Pierdes y se restan los valores de la secuencia."
      ((mmoeny -= bet))
      unset my_sequence[0]
      if [ $fl -eq 0 ]; then
        unset my_sequence[-1]
      fi
    elif [ "$(($out % 2))" -eq $nm ]; then
      echo -e "Has ganado. Se agrega el nuevo valor a la secuencia."
      my_sequence+=($bet)
      ((money += bet))
    else 
      echo -e "Has perdido. Se restan los valores de la secuencia."
      ((money -= bet))
      unset my_sequence[0]
      if [ $fl -eq 0 ]; then
        unset my_sequence[-1]
      fi
    fi 
    my_sequence=(${my_sequence[@]})
    sleep 10
  done
  tput cnorm
}

function martingala() {
  declare -i nm=1 
  declare -i counter=0
  money="$1"
  losing_streak=""
  declare -i max=$money
  echo -e "${yellowColour}{+}${endColour} ${grayColour}Tienes${endColour} ${yellowColour}$money${endColour} ${grayColour}dolares${endColour}"
  echo -en "${yellowColour}{+}${endColour} ${grayColour}Cuanto dinero quieres apostar ->${endColour} " && read bet
  echo -ne "${yellowColour}{+}${endColour} ${grayColour}A que apuestas -> ${endColour}" && read w

  if [ "$w" == "par" ]; then
    nm=0
  fi
  ori_bet=$bet
  tput civis
  while true; do 
    if [ $money -le 0 ]; then 
      echo -e "\n${redColour}{+} Te has quedado sin dinero${endColour}\n"
      echo -e "${yellowColour}{+} ${grayColour}Se jugaron${endColour} ${yellowColour}$counter${endColour} ${grayColour}rondas${endColour}\n"
      echo -e "${yellowColour}{+} ${grayColour}Lo maximo que lograste conseguir fue${endColour} ${yellowColour}$max${endColour}\n"
      echo -e "${yellowColour}{+} ${grayColour}La ultima racha perdedora fue:\n${endColour}\n${blueColour}\t[$losing_streak]${endColour}\n"
      tput cnorm; exit 0
    fi
    let counter+=1
    #echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Tienes${endColour} ${yellowColour}$money${endColour} ${grayColour}y apostaras${endColour} ${yellowColour}$bet${endColour}"
    out="$(($RANDOM % 37))"
    #echo -e "\t${yellowColour}{+}${endColour} ${grayColour}Ha salido el numero${endColour} ${yellowColour}$out${endColour}"
    if [ $out -eq 0 ]; then 
      money=$(($money - $bet))
      losing_streak+="$out "
     # echo -en "\t${redColour}{+} La casa gana"  
      ((bet *= 2))
    elif [ "$(($out % 2))" -eq $nm ]; then 
      money=$(($money + $bet))
      losing_streak=""
      if [ $money -gt $max ]; then
        max=$money
      fi
      #echo -en "\t${greenColour}{+} Has ganado"
      bet=$ori_bet
    else 
      money=$(($money - $bet))
      losing_streak+="$out "
      #echo -en "\t${redColour}{+} Has perdido"
      ((bet *= 2))
    fi
    #echo -e ". Ahora tienes${endColour} ${yellowColour}$money${endColour}"
  done 
  tput cnorm
}



while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) tech=$OPTARG;;
    h) help_panel;;
  esac
done

if [ $money ] && [ $tech ]; then
  if [ "$tech" == "martingala" ]; then
    martingala $money

  elif [ "$tech" == "inverseLabrouchere" ]; then
    inverse_labrouchere $money
  else
    echo -e "\n${redColour}{!} Esa tecnica no existe.${endColour}"
    help_panel
  fi
else 
  help_panel
fi


