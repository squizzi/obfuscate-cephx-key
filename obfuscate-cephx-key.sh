#!/bin/bash
## obfuscate-cephx-key
## Created by: Kyle Squizzato - ksquizza@redhat.com

# This script extracts an sosreport and obfuscates the cephx key visible
# in plain text inside each of the qemu process lists that are ran as part
# of the 'process' plugin for sosreport as well as the cephx key visible in
# /var/log/libvirt/qemu/*.log

# This script will be obsolete when an errata for BZ #1245647 is released which
# addresses the qemu vulnerability

# The only required parameter is the sosreport you wish to clean
if [ $# -ne 1 ]; then
        echo "Usage : $0 <sosreport to be cleaned>"
        exit 1
fi
# Take the sosreport file as a parameter
[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"

# Recommend root as sos likes to have odd permissions sometimes
# and running as root is the easiest way around it
if [ "$(id -u)" != "0" ]; then
   echo "Warning: If script is not run as root, permission errors may occur"
   read -p "Continue Y/N? " -n 1 -r
   echo
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
     exit 1
   fi
fi

# Extract the files to be edited from sosreport given as an argument
if [ -e /bin/tar ]; then
  echo "Extracting $1 to a temporary directory inside $(pwd)..."
  mkdir -p obfuscate_tmp/
  tar xf $1 -C $(pwd)/obfuscate_tmp/
else
  echo "tar not found, cannot extract sosreport, exiting"
  exit 1
fi

# Find and replace each of the cephx auth keys in sos_commands/process/ and
# /var/log/libvirt/qemu/ with *******
echo "Finding and replacing all instances of cephx auth keys, this may take a few moments to complete..."
find obfuscate_tmp/sosreport-*/sos_commands/process/. -type f -exec sed -i 's/key=[^:]\+:/key=*******:/g' {} \;
find obfuscate_tmp/sosreport-*/var/log/libvirt/qemu/. -type f -exec sed -i 's/key=[^:]\+:/key=*******:/g' {} \;

# tar everything back up into a new sosreport marked as cleaned
echo 'Creating a new sosreport with the cleaned files...'
cd obfuscate_tmp/
tar cJf cephx-cleaned-$(basename $1) sosreport-*
mv cephx-cleaned-$(basename $1) ..
cd $OLDPWD

# Remove obfuscate_tmp
echo 'Cleaning up...'
rm -rf obfuscate_tmp/
echo "Done."
echo "New sosreport created as cephx-cleaned-$(basename $1) in $(pwd)"
