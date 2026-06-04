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

#Ctrl + c
function ctrl_c() {
  echo -e "\n\n${redColour}{!} Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function help_panel() {
  echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Uso:${endColour}\n" 
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Filtrar maquinas por nivel de dificultad${endColour}" 
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}" 
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por ip de la maquina${endColour}" 
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de maquina${endColour}" 
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por alguna skill${endColour}" 
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos neceserios${endColour}" 
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Mostrar link de resolucion de la maquina${endColour}\n"

}

function update_files() { 
  tput civis
  if [ -f bundle.js ]; then
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Comprobando actualizaciones...${endColour}"
  else 
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Descargando archivos...${endColour}"
  fi
  curl -s -X GET $main_url | js-beautify > temp_bundle.js
  temp_value=$(md5sum temp_bundle.js | cut -d ' ' -f 1)
  if [ -f bundle.js ]; then
    original_value=$(md5sum bundle.js | cut -d ' ' -f 1)

    if [ "$temp_value" == "$original_value" ]; then  
      echo -e "\n${yellowColour}{+} ${grayColour}No hay actualizaciones.${endColour}"
      rm temp_bundle.js
    else 
      echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Actualizando archivos...${endColour}"
      sleep 0.5
      mv temp_bundle.js bundle.js 
      echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Archivos actualizados.${endColour}"
    fi
  else 
    mv temp_bundle.js bundle.js
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Todos los archivos se han descargado correctamente.${endColour}"
  fi
  tput cnorm
}

function search_machine() {
  name="$1" 
  status="$(cat bundle.js | grep "name: \"$name\"")"
  if [ ! "$status" ]; then
    echo -e "\n${redColour}{!} No se encontro una maquina con este nombre${endColour}\n"
  else 
    details="$(cat bundle.js | awk "/name: \"$name\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Listando propiedades de la maquina ${blueColour}$name${endColour}${grayColour}:${endColour}\n"
    echo -e "${details}"
  fi
}

function search_ip() {
  where="$1"
  status="$(cat bundle.js | grep "ip: \"$where\"")"
  if [ ! "$status" ]; then
    echo -e "\n${redColour}{!} No se encontro una maquina con esta ip.${endColour}\n"
  else 
    name="$(cat bundle.js | grep "ip: \"$where\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '\"' | tr -d '\,')"
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}La maquina con la ip ${blueColour}$where${endColour} ${grayColour}es:${endColour} ${purpleColour}$name${endColour}\n"
  fi
}

function search_video() {
  name="$1"
  status="$(cat bundle.js | grep "name: \"$name\"")"
  if [ "$status" ]; then
    link="$(cat bundle.js | grep "name: \"$name\"" -A 10 | sed 's/^ *//' |  grep "youtube: " | cut -d '"' -f 2)"
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Enlace a la resolucion de la maquina:${endColour} ${blueColour}$link${endColour}\n"
  else 
    echo -e "\n${redColour}{!} No se encontro una maquina con este nombre${endColour}\n"
  fi
}

function sort_level() {
  level="$1"
  status="$(cat bundle.js | grep "dificultad: \"$level\"")"
  if [ "$status" ]; then
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Maquinas de nivel${endColour} ${blueColour}$level${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "dificultad: \"$level\"" -B 5 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | sort | column
  else 
    echo -e "\n${redColour}{!} No se encontro una maquina con ese nivel de dificultad${endColour}\n"
  fi 
}

function sort_os() {
  os="$1"
  status="$(cat bundle.js | grep "so: \"$os\"")"
  if [  "$status" ]; then 
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Maquinas con SO${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | sed 's/^ *//' | awk 'NF{print $NF}' | tr -d '",' | sort | column
  else 
    echo -e "\n${redColour}{!} No se encontro una maquina con ese sistema operativo${endColour}\n"
  fi 
}

function sort_skill() {
  skill="$1"
  status="$(cat bundle.js | grep -i "skills: .*$skill.*")"
  if [ "$status" ]; then
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Maquinas con la skill${endColour} ${blueColour}$skill${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep -i "skills: .*$skill.*" -B 6 | sed 's/^ *//' | grep "name: " | tr -d ',"' | awk 'NF{print $NF}' | sort | column
  else
    echo -e "\n${redColour}{!} No se encontro una maquina con esa skill${endColour}\n"
  fi 
}

function combine_level_os() {
  level="$1"
  os="$2"
  name="$(cat bundle.js | grep "so: \"Linux\"" -C 4 | grep "dificultad: \"Media\"")"
  if [ "$name" ]; then
    echo -e "\n${yellowColour}{+}${endColour} ${grayColour}Maquinas de nivel${endColour} ${blueColour}$level${endColour}${grayColour} y sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$level\"" -B 5 | sed 's/^ *//' | grep "name: " | awk 'NF{print $NF}' | tr -d ',"' | sort | column
  else 
    echo -e "\n${redColour}{!} No se encontro una maquina con ese sistema operativo y nivel de dificultdad${endColour}\n"
  fi
}

#Indicators
declare -i parameter_counter=0

#Chivato
declare -i clevel_os=0

while getopts "d:m:hi:o:s:uy:" arg; do
  case $arg in
    d) level=$OPTARG; let clevel_os+=1; let parameter_counter+=5;;
    m) machine=$OPTARG; let parameter_counter+=1;;
    h) ;;
    i) ip=$OPTARG; let parameter_counter+=3;;
    u) let parameter_counter+=2;;
    o) os=$OPTARG; let clevel_os+=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    y) machine=$OPTARG; let parameter_counter+=4;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  search_machine "$machine"
elif [ $parameter_counter -eq 2 ]; then
  update_files 
elif [ $parameter_counter -eq 3 ]; then 
  search_ip $ip
elif [ $parameter_counter -eq 4 ]; then
  search_video "$machine"
elif [ $parameter_counter -eq 5 ]; then
  sort_level $level
elif [ $parameter_counter -eq 6 ]; then
  sort_os $os
elif [ $parameter_counter -eq 7 ]; then 
  sort_skill "$skill"
elif [ $clevel_os -eq 2 ]; then
  combine_level_os $level $os
else 
  help_panel
fi
