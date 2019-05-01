red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

while true; do
    sleep 1
    OUTPUT=$(curl --silent http://www.istio.missena.xyz)
if [[ "$OUTPUT" == "Hello v2!" ]]; then
   echo "${green}${OUTPUT}${reset}"
elif [[ "$OUTPUT" == "Hello v1!" ]]; then
    echo "${red}${OUTPUT}${reset}"
else
    echo "${OUTPUT}"
fi
done

