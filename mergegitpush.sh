#Purpose -> merge dev to master for ios
#Created on 2-JUL-2016
#Author = John Meah
#Version 1.0

#Push to AWS
echo "checking out master..."
git checkout master

echo "merging with dev via 'git merge --no-edit -X theirs dev'..."
git merge --no-edit -X theirs dev

echo "finished merge check output before push..."

