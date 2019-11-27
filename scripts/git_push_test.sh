#!/bin/bash

scriptDir=$PWD


git add $scriptDir/..
git commit -am "source file upload"

git pull origin backup
git push origin backup

