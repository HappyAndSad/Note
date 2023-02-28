#!/bin/sh

git filter-branch -f --env-filter '

an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"


oldName="flybear"
oldEmail="flybear@xiongzedeMBP.lan"
newName="HappyAndSad"
newEmail="32348628+HappyAndSad@users.noreply.github.com"

if [ "$GIT_COMMITTER_EMAIL" = "$oldEmail" ]
then
    cn="$newName"
    cm="$newEmail"
fi

if [ "$GIT_COMMITTER_NAME" -eq "$oldName" ]
then
    cn="$newName"
    cm="$newEmail"
fi


if [ "$GIT_AUTHOR_EMAIL" = "$oldEmail" ]
then
    an="$newName"
    am="$newEmail"
fi

if [ "$GIT_AUTHOR_NAME" -eq "$oldName" ]
then
    an="$newName"
    am="$newEmail"
fi

export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'
