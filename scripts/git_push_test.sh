#!/bin/bash

scriptDir=$PWD


git checkout backup
git add $scriptDir/..
git commit -am "source file uploadt"

git pull origin backup
git push origin backup

