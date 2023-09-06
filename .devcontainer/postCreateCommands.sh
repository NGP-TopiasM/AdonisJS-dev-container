#!/bin/bash

FOLDER=service

set -a
source .devcontainer/.env
set +a

function setupPg() {
    npm i @adonisjs/lucid pg luxon
    
    sed -i 6's/$/,&/' .adonisrc.json
    sed -i '7 i \ \ \ \ "@adonisjs/lucid/build/commands"' .adonisrc.json
    sed -i '/\@adonisjs\/core"/ s/^\(.*\)\("\)/\1", "\@adonisjs\/lucid\"/' .adonisrc.json
    
    sed -i '/adonis\-typings/ s/^\(.*\)\("\)/\1", "\@adonisjs\/lucid\"/' tsconfig.json

    echo "DB_CONNECTION=pg" >> .env
    echo "PG_HOST=localhost" >> .env
    echo "PG_PORT=5432" >> .env
    echo "PG_USER=postgres" >> .env
    echo "PG_PASSWORD=postgres" >> .env
    echo "PG_DB_NAME=postgres" >> .env
    
    echo "DB_CONNECTION=pg" >> .env.example
    echo "PG_HOST=localhost" >> .env.example
    echo "PG_PORT=5432" >> .env.example
    echo "PG_USER=postgres" >> .env.example
    echo "PG_PASSWORD=postgres" >> .env.example
    echo "PG_DB_NAME=postgres" >> .env.example
    
    sed -i '24 i \ \ DB_CONNECTION: Env.schema.string(),' env.ts
    sed -i '25 i \ \ PG_HOST: Env.schema.string(),' env.ts
    sed -i '26 i \ \ PG_PORT: Env.schema.number(),' env.ts
    sed -i '27 i \ \ PG_USER: Env.schema.string(),' env.ts
    sed -i '28 i \ \ PG_PASSWORD: Env.schema.string.optional(),' env.ts
    sed -i '29 i \ \ PG_DB_NAME: Env.schema.string(),' env.ts
    
    cp .devcontainer/resources/database.ts config/database.ts
}

function setupRedis() {
    npm i @adonisjs/redis
    
    echo "REDIS_CONNECTION=local" >> .env
    echo "REDIS_HOST=127.0.0.1" >> .env
    echo "REDIS_PORT=6379" >> .env
    echo "REDIS_PASSWORD=" >> .env
    
    echo "REDIS_CONNECTION=local" >> .env.example
    echo "REDIS_HOST=127.0.0.1" >> .env.example
    echo "REDIS_PORT=6379" >> .env.example
    echo "REDIS_PASSWORD=" >> .env.example
    
    sed -i '/lucid/ s/^\(.*\)\("\)/\1", "\@adonisjs\/redis\"/' tsconfig.json
    sed -i '/\@adonisjs\/lucid"/ s/^\(.*\)\("\)/\1", "\@adonisjs\/redis\"/' .adonisrc.json
    
    sed -i "30 i \ \ REDIS_CONNECTION: Env.schema.enum(['local'] as const)," env.ts
    sed -i "31 i \ \ REDIS_HOST: Env.schema.string({ format: 'host' })," env.ts
    sed -i "32 i \ \ REDIS_PORT: Env.schema.number()," env.ts
    sed -i "33 i \ \ REDIS_PASSWORD: Env.schema.string.optional()," env.ts
    
    cp .devcontainer/resources/redis.ts config/redis.ts
}

function setupPrivateNpm() {
    touch .npmrc
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> .npmrc
    echo ".npmrc" >> .gitignore

    npm install @clearvue/adonis-auth-middleware@latest
}

function configNamespaces() {
    sed -i '9 i \ \ "namespaces": {' .adonisrc.json
    sed -i '10 i \ \ \ \ "models": "App/Repositories/Models"' .adonisrc.json
    sed -i '11 i \ \ },' .adonisrc.json
}

function installCommonLibraries() {
    npm i lodash @types/lodash
    npm i axios
    npm i kafkajs
}

function createConstsFile() {
    mkdir app/Data
    touch app/Data/Consts.ts
    
    echo "/*" >> app/Data/Constants.ts
    echo "Example of ENUM values and type:" >> app/Data/Constants.ts
    echo "export const ENUM_THINGS = ['foo', 'bar'] as const" >> app/Data/Constants.ts
    echo "export type EnumThing = (typeof ENUMS_THINGS)[number]" >> app/Data/Constants.ts
    echo "*/" >> app/Data/Constants.ts
}

if [ ! -f ".env.example" ]
then
    # Create AdonisJS project
    if [ -n "$PROJECT_NAME" ]; then
        npm install create-adonis-ts-app@4.2.4 --no-save --prefix ./ && npm init adonis-ts-app $FOLDER -- --boilerplate=api --eslint --prettier --name=$PROJECT_NAME 
    else
        npm install create-adonis-ts-app@4.2.4 --no-save --prefix ./ && npm init adonis-ts-app $FOLDER -- --boilerplate=api --eslint --prettier
    fi
    
    rm -r node_modules

    cd $FOLDER && find . -mindepth 1 -maxdepth 1 -exec mv -t .. -- {} +
    cd .. && rm -r $FOLDER

    echo ".devcontainer/.env" >> .gitignore
    cp .devcontainer/resources/.eslintrc.json .eslintrc.json

    setupPg
    setupRedis
    cp .devcontainer/resources/MakeRepo.ts commands/ # Make repository command
    node ace generate:manifest

    if [ -n "$NPM_TOKEN" ]; then setupPrivateNpm; fi;

    installCommonLibraries
    configNamespaces
    createConstsFile
else 
    cp .env.example .env

    npm install
fi
