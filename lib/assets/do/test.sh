#!/usr/bin/env bash

PROJECT_DIR="/home/ubuntu/website"

cd $PROJECT_DIR

git_get(){
        echo "Pulling out latest changes from master.."
        git fetch --all
        git checkout master
        git pull origin master
}

git_get

bundle install

rails restart
