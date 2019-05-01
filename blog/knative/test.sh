red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

while true; do
    sleep 1
    OUTPUT=$(curl --silent -H 'Host: helloworld-go.default.example.com' a2f760ed56ab511e995b0069b3f28ec6-1656798546.eu-west-1.elb.amazonaws.com)
if [[ "$OUTPUT" == "Hello v2!" ]]; then
   echo "${green}${OUTPUT}${reset}"
elif [[ "$OUTPUT" == "Hello v1!" ]]; then
    echo "${red}${OUTPUT}${reset}"
else
    echo "${OUTPUT}"
fi
done
