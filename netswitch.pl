#!/usr/bin/perl

# A script for changing links to correct network files, and resetting 
# the network interface with the new settings

# Written 98/11/08 by Brian Manning

# Inspired by a script from Neil Schneider and a lot of other KPLUGers
# for the boxen Pandora at the Computer Expo

# This script assumes that you have a bunch of different config 
# files for your network adapter, and that you copy the template files over
# the old config files

# This script will search for the file "/etc/network/interfaces.*" and 
# "/etc/network/resolv.conf.*" and return all config files that it finds, so
# the user can choose which one to run. (example: interfaces.test,
# interfaces.foo, etc.) Then the script will copy out the files over the old
# ones, and restart the interface.

# clear the screen
system('clear');

# sanity check
print $ENV{"USER"} . " is current user\n\n";

if ( $ENV{"USER"} != "root" ) {
    print STDOUT "\n\n\nBzzzt! Must be root to run this script...\n\n\n";
    exit;
} # if $ENV{$USER}

print $ENV{"SCHEME"} . " is the scheme\n";

# well, why are we here?
if ( -z $ENV{"SCHEME"} ) {
    # the $SCHEME was borrowed from PCMCIA, and should play nicely
	print "netswitch.pl\n";
    print "This script will configure the network settings for this machine\n";
	print "\nPlease choose one of the following configs...\n\n";

    # display the current config files
	$counter=1;					#set counter
    
    # load an array with all the files from /etc/network
    @netconfigs = </etc/network/*>;
    
    # go through all of the files in the directory
	foreach $netfile (@netconfigs) {
        print "DEBUG: netfiles is $netfile\n";
		if (/interfaces./) { # is this an interfaces file?
            if (/interfaces/) { # is it THE interfaces file?
                print "unlinking $netfile which should be interfaces\n";
            } # if (/interfaces/)
        } # if (/interfaces./)
		$counter=$counter +1;			#update counter
    } # foreach $netfiles

# read the desired network configuration
	print "\nPlease type in the number of the congfig to enable\n";
	print "Type the number '0' to exit\n";
	$config_name = <STDIN>;			#read in the desired config

} # if $ENV{SCHEME}

# now change over to the new config
	#echo
	#echo $config_name
#	if [ $config_name != "0" ]; then 	#if the input is non-zero
#	counter=1 
#	for netfiles in /etc/network/interfaces.*		#start file loop
#	  do
#		if [ $counter = $config_name ]; then
#			echo Bringing down eth0
#			/sbin/ifdown eth0			# bring the interface down first
#
#			# let them know what config we are going to
#			echo Changing config to ${netfiles#*.conf.}
#			echo
#			echo Linking resolv.conf to /etc/resolv.conf.${netfiles#*.conf.}
#
#			# resolve files
#			if [ -L /etc/resolv.conf ]; then	
#				rm /etc/resolv.conf
#			fi
#			ln -s /etc/network/resolv.conf.${netfiles#*.conf.} /etc/resolv.conf
#
#			# network files
#			echo Linking network to /etc/network/interfaces.${netfiles#*.conf.}
#			if [ -L /etc/network/interfaces ]; then
#				rm /etc/network/interfaces
#			fi
#			ln -s /etc/network/interfaces.${netfiles#*.conf.} \
#                /etc/network/interfaces
#
#		fi # if [ $counter = $config_name ] 
#		counter=$((counter+1))          #update counter
#	  done # for netfiles 
#	fi # if [ $config_name != "0" ]
#	echo
#	echo Bringing up eth0 with new config
#	/sbin/ifup eth0
exit 0
