#!/usr/bin/env bash

# create dirs which will contains desired repos
mkdir net-without-net-core
mkdir net-core-only

# remove all but net dir
# git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
cd linux-2.6
git filter-branch -f --subdirectory-filter net HEAD -- --all
git remote rm origin

# now clone net repo two times for further processing 
git clone --no-hardlinks ./ ../net-without-net-core
git clone --no-hardlinks ./ ../net-core-only

# net-without-net-core at first
cd ../net-without-net-core
git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch core" HEAD -- --all
# remove local origin
git remote rm origin
# remove backed up master ref
git update-ref -d refs/original/refs/heads/master
# clear reflog
git reflog expire --expire=now --all
# repack all objects to single compressed file
git repack -ad
# then collect garbage
git gc --aggressive --prune=now
# add new remote
git remote add origin git@github.com:Yankovsky/net-without-net-core.git
# copy this script and push to github
cp ../git-separate-repositories.sh ./
git add .
git commit -am "net without net core initial commit"
#git push origin master

# net-core-only by analogy with previous
cd ../net-core-only
git filter-branch -f --subdirectory-filter core HEAD -- --all
git remote rm origin
git update-ref -d refs/original/refs/heads/master
git reflog expire --expire=now --all
git repack -ad
git gc --aggressive --prune=now
git remote add origin git@github.com:Yankovsky/net-core-only.git
cp ../git-separate-repositories.sh ./
git add git-separate-repositories.sh
git commit -am "net core only initial commit"
#git push origin master

# clean up
cd ..
#rm -r linux-2.6
