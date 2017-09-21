#Purpose -> gitpush in one command.
#Version 1.0
#set -v verbose #echo on

echo -n "Enter the details of your deployment (i.e. 4-FEB-2014 Updating this script.) > "
read comment
echo "You entered $comment"

#Push to AWS
echo "Committing to git..."
git add . 
git commit -m "$comment"
echo "Pushing to github..."
git push 
