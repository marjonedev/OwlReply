#!/usr/bin/env bash

PROJECT_DIR="/home/ubuntu/website"

cd $PROJECT_DIR

BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

git fetch --all

git_deploy(){
        echo "Pulling out latest changes from master.."
        git fetch --all
        git checkout master
        git pull origin master
        echo "Creating new production branch.."
        git checkout -b $1 master
        git push origin $1
        echo "Done! The current branch now is $1"
}

FORCE=false
VERSION=0

while getopts f: option
do
case "${option}"
in
        f) FORCE=true
                VERSION=${OPTARG}
                break ;;
        *) exit 0 ;;
esac
done



if [ $FORCE = true ]
then
        branch_name="production_v$VERSION"
        if [ $(git branch -a | egrep "remotes/origin/$branch_name$") ]
        then
                echo "Remote branch $branch_name is already exist!"
                exit 0;
        fi

        NEW_BRANCH="production_v$VERSION"
        git_deploy $NEW_BRANCH
        exit 0;
fi


PREPROD=$(echo $BRANCH | cut -c1-10)

if [ $PREPROD = "production" ]
then
        CURRENT_VERSION=$(echo $BRANCH| cut -d'v' -f 2)
        NEW_VERSION=$(echo "$CURRENT_VERSION + 0.1" | bc)
        NEW_BRANCH="production_v$NEW_VERSION"

        git_deploy $NEW_BRANCH
else
        echo "The current branch is $BRANCH and is not in production.. Please checkout current branch to production."
        exit 1;