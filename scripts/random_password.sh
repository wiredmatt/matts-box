#!/bin/sh

__FILE=~/root_$(hostname)

__PASSWORD=$(openssl rand -base64 12)

echo "root:$__PASSWORD" > $__FILE

cat $__FILE |chpasswd

echo "ready. can now upload the file $__FILE"

# contents of $__FILE will be:
# root:randompassword
# 
# then you can upload this file to another safe box, or cloud storage and forget about it.
# if you ever need to do mainteinance as root, for whatever reason, you can look for it
# wherever you uploaded it.
# you should be able to keep this file in this box, but, you can of course delete it too
# just run `rm -rf $__FILE` after running this. 
