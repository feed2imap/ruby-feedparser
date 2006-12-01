#!/bin/bash

if [ -z $CVSDIR ]; then
	CVSDIR=$HOME/dev/ruby-feedparser/website
fi

TARGET=$CVSDIR/rdoc

echo "Copying rdoc documentation to $TARGET."

if [ ! -d $TARGET ]; then
	echo "$TARGET doesn't exist, exiting."
	exit 1
fi
rsync -a rdoc/ $TARGET/

echo "###########################################################"
echo "CVS status :"
cd $TARGET
svn st
echo "CVS Adding files."
while [ $(svn st | grep "^? " | wc -l) -gt 0 ]; do
	svn add $(svn st | grep "^? " | awk '{print $2}')
done
echo "###########################################################"
echo "CVS status after adding missing files:"
svn st
echo "Commit changes now with"
echo "# (cd $TARGET && svn commit -m \"rdoc update\")"
exit 0
