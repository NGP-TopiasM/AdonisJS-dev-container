#!/bin/bash
if [ ! -f ".env" ]; then cp .env.example .env; fi

# If theres no .npmrc ask for it
if [ ! -f ".npmrc" ]; then
  read -n 1 -p "Set NPM auth token (y/n)? " answer
  printf "\n"
  case ${answer:0:1} in
    y|Y )
      read -p "Insert token: " token
      echo "//registry.npmjs.org/:_authToken=${token}" >> .npmrc
      printf '\n.npmrc created!'
    ;;
  esac  
fi

npm install

node ace migration:fresh
