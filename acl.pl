#!/usr/bin/perl

# acl.pl - Advanced Color Logs
$version = "0.7.0";

# written by Patrick Mullen (p_mullen@linuxmail.org)
#
# VISIT THE LINUX RESOURCE CENTER -- http://www.LinuxRC.org
#
# The LATEST VERSION of this program can be found at
# http://www.LinuxRC.org/projects/acl 
#
# USAGE
# acl.pl [-f <configfile>] < file.to.colorize
#
# Default config file is acl.conf, and is searched for in
# the path ".:$HOME/.acl:/etc/acl".  An alternate config file
# may be specified using the -f command-line parameter.

use Getopt::Long;

# Create the colors Assoc. Array
%colors = (
    'default'            => "\033[0m",
    'black'              => "\033[30m",
    'red'                => "\033[31m",
    'green'              => "\033[32m",
    'yellow'             => "\033[33m",
    'blue'               => "\033[34m",
    'magenta'            => "\033[35m",
    'cyan'               => "\033[36m",
    'white'              => "\033[37m"
);

%attributes = (
    'normal'             => "\033[00m",
    'bright'             => "\033[01m",
    'underlined'         => "\033[04m",
    'blinking'           => "\033[05m",
    'background'         => "\033[07m",
    'beep'               => "\007",
    'wake'               => "\033[13]"
);   

$normal = $colors{default};

$timestampexp = '[A-S][a-u][b-y] [0-9 ][0-9] [0-2][0-9]:[0-6][0-9]:[0-6][0-9]';
$timestampcolor = $attributes{'bright'}.$colors{'blue'};
$defaulthostnamecolor = $attributes{'bright'}.$colors{'green'};
$servicecolor   = $attributes{'bright'}.$colors{'yellow'};

GetOptions("f=s" => \$configfile, "file=s" => \$configfile, "info" => \$infoarg,
      "version" => \$versionarg, "help" => \$helparg, 
      "syslog" => \$syslog, "wake" => \$wake, "nosyslog" => \$nosyslog,
      "nowake" => \$nowake) or die &print_help;

if($infoarg) {
   &program_info; exit;
}  elsif($helparg) {
   &print_help; exit;
}  elsif($versionarg) {
   print "$version\n"; exit; 
}

$configdir = "/usr/local/etc";
$hconfigdir = "$ENV{'HOME'}/.acl";
$configfile = ($configfile || "acl.conf");
$legacyconfigfile = "/etc/acl.conf";
$configfile = &find_configfile($configfile);

open CFG, $configfile or die "Error opening configuration file $configfile.  Exiting.\n";

$maxindex = 0;

while(<CFG>) {

   chomp;
	# Strip comments
	s/:.*$//;

	# Next line if line is empty now:
	next if (/^\s*$/);

        # Chomp out the whitespace
        s/^\s*//;
        s/\s*$//;

        # Search for special characters
        s/\~/\\\~/g;
#        s/\!/\\\!/g;   # We use ! to denote a line is NOT to have a string
			# May want to make this smarter, ie don't substitute
			# if we find ",!" or ",[whitespace]!"
        s/\@/\\\@/g;
        s/\#/\\\#/g;
        s/\$/\\\$/g;
        s/\%/\\\%/g;
        s/\^/\\\^/g;
        s/\&/\\\&/g;
        s/\*/\\\*/g;
        s/\-/\\\-/g;
        s/\_/\\\_/g;
        s/\=/\\\=/g;
        s/\+/\\\+/g;
        s/\[/\\\[/g;
        s/\]/\\\]/g;
        s/\{/\\\{/g;
        s/\}/\\\}/g;
        s/\|/\\\|/g; 
        s/\"/\\\"/g;
        s/\;/\\\;/g;
        s/\</\\\</g;
        s/\>/\\\>/g;
        s/\?/\\\?/g;
        s/\(/\\\(/g;
        s/\)/\\\)/g;
        s/\`/\\\`/g;
        s/\'/\\\'/g;

   if(/^option/i) { 
      ($tag, $option) = split(/\s*,(.*)/);

      for($option) {
         /syslog/i && do { $syslog = 1; last; };
         /wake/i   && do { $wake   = 1; last; };
         die("Unknown option in config file: $option");
      }

      next;
   }

   if(/^host/i) {
      s/ //g;   # We don't care about spaces; they can't be in hostnames.
                # By stripping them it makes our associative array easier.
      ($tag, $host, $colorconfig) = split(/\,/, $_, 3);
      $hosts{$host} = &parse_color($colorconfig);

      next;
   }

   if(/^timestamp/i) {
      ($tag, $colorconfig) = split(/\,/, $_, 2);
      $timestampcolor = &parse_color($colorconfig);
      next;
   }

   if(/^service/i) {
      s/ //g;   # We don't care about spaces; they can't be in servicenames.
                # By stripping them it makes our associative array easier.
                # If the above is incorrect, this part will break, as will
                # the parsing of lines further down.
      ($tag, $service, $colorconfig) = split(/\,/, $_, 3);
      $services{$service} = &parse_color($colorconfig);

      next;
   }

#ZDNOTE: Can this be made into one split?

   ($colorconfig, $rest_of_line) = split(/\s*,(.*)/);
 
   $_ = $rest_of_line;
   ($primary_match, $secondary_matches) = split(/\s*,(.*)/);

   $search_strings{$maxindex, 'color'} = &parse_color($colorconfig);
   $search_strings{$maxindex, 'primary_match'} = $primary_match;
   $search_strings{$maxindex, 'secondary_matches'} = $secondary_matches;
   $search_strings{$maxindex, 'hide'} = ($colorconfig =~ /hide/i);

   $maxindex++;
}


# If command line was used to override config file options, we
# need to account for them here.

if($nowake)   { $wake   = 0; }
if($nosyslog) { $syslog = 0; }


# The main loop.  Process each input line and print them in color.

while($line = <>) {
   $found = 0;
   chomp($line);

   for($index = 0; $index < $maxindex; $index++) {

      $color = $search_strings{$index, 'color'};
      $primary_match = $search_strings{$index, 'primary_match'};
      $secondary_matches = $search_strings{$index, 'secondary_matches'};
      $hide = $search_strings{$index, 'hide'};

      if($primary_match && $line =~ /$primary_match/) {

         $found = 1;

         $rest_of_line=$secondary_matches;

         while($rest_of_line) {
            $_ = $rest_of_line;
            ($string, $rest_of_line) = split(/\s*,(.*)/);

            if(grep(/^!/, $string)) {
               if($line =~ substr($string, 1)) {
                  $found = 0;
               } 
            }  else {
               if($line !~ $string) {
                  $found = 0;
               }
            }
         }

         if($found) { last; }
      }
   }

   if(!$found) { $color = $default; $hide = 0; }

   # This is just until I get it set up with independent colors
#   $servicecolor = $color;

   if(!$hide) {

      if($wake) { print $attributes{'wake'}; }

      if($syslog) {
         if($line =~ /($timestampexp)\s+(\S+)\s+(\S+:)\s+(.*)/) {
            $hostnamecolor = $defaulthostnamecolor;
            foreach(keys %hosts) {
               if($2 =~ /$_/i) { $hostnamecolor = $hosts{$_}; last; }
            }
            $servicecolor = $color;  # If we don't have one specificly for this service, 
                                     # color it with rest of line.
            foreach(keys %services) {
               if($3 =~ /$_/i) { $servicecolor = $services{$_}; last; }
            }
            $line = "$normal$timestampcolor$1$normal $hostnamecolor$2$normal $servicecolor$3$normal$color $4";
         }  elsif($line =~ /($timestampexp)\s+(\S+)\s+(.*)/) {
            $hostnamecolor = $defaulthostnamecolor;
            foreach(keys %hosts) {
               if($2 =~ /$_/i) { $hostnamecolor = $hosts{$_}; last; }
            }
            # This format doesn't have a servicename
            $line = "$normal$timestampcolor$1$normal $hostnamecolor$2$normal$color $3";
         }  else {
            $line = $color.$line;
         }
      }  else {
         $line = $color.$line;
      }

      print "$line$normal\n";
   }

}

sub parse_color {
   local($colorconfig) = @_;
   local($color);

   # This is a switch/case statement(!), see man perlsyn
   for ($colorconfig) {
      /black/i   && do { $color = $colors{'black'};   last; };
      /red/i     && do { $color = $colors{'red'};     last; };
      /green/i   && do { $color = $colors{'green'};   last; };
      /yellow/i  && do { $color = $colors{'yellow'};  last; };
      /blue/i    && do { $color = $colors{'blue'};    last; };
      /magenta/i && do { $color = $colors{'magenta'}; last; };
      /cyan/i    && do { $color = $colors{'cyan'};    last; };
      /white/i   && do { $color = $colors{'white'};   last; };
      $color = $colors{'default'};
   }

   for ($colorconfig) {
      $color=$color.$attributes{'normal'}     if(/normal/i);
      $color=$color.$attributes{'bright'}     if(/bright/i);
      $color=$color.$attributes{'underlined'} if(/underlined/i);
      $color=$color.$attributes{'blinking'}   if(/blinking/i);
      $color=$color.$attributes{'background'} if(/background/i);
      $color=$color.$attributes{'beep'}       if(/beep/i);
      $color=$color.$attributes{'wake'}       if(/wake/i);
   }

   $color;
}



sub find_configfile() {
   # Try to get config in several places:
   my @try=("$_[0]", "$_[0].conf", 
      "$hconfigdir/$_[0]", "$hconfigdir/$_[0].conf",
      "$configdir/$_[0]", "$configdir/$_[0].conf",
      "$legacyconfigfile");
   foreach (@try) { return $_ if (-r $_); }

   # More files than this are tried, but for cosmetic reasons we don't
   # want to display that we tried files like "acl.conf.conf".
   $errormsg = "Could not find any of these files:\n";
   $errormsg = $errormsg."\t./$_[0]\n";
   $errormsg = $errormsg."\t$hconfigdir/$_[0]\n";
   $errormsg = $errormsg."\t$configdir/$_[0]\n";
   $errormsg = $errormsg."\t$legacyconfigfile\n";
   die($errormsg);
}

sub program_info() {
   print "Advanced Color Logs $version by ";
   print "Patrick Mullen \<p_mullen\@linuxmail.org\>\n\n";
   &print_help;

print<<EndOfInformation;

The default configuration file is named acl.conf and will be searched for in
the following path: '.:\$HOME/.acl:/etc/acl'.
For backwards compatibility, /etc/acl.conf may also be used.

The configuration file consists of comma separated fields:
'Color/Attributes, primary search string, additional strings'

The primary search string must be found in the line to match, but additional 
strings can be either found in the line, or they can be specified as not being
in a line by preceding the string with '!'.

Valid colors are magenta, blue, yellow, green, red, cyan, white, and black.
Valid attributes are normal, underlined, blinking, bright, and background.
In addition, beep is a valid attribute as well as hide.
EndOfInformation
}

sub print_help() {
print<<EndOfHelp;
-help    => Help (this)
-info    => Program information
-version => Program version
-file    => Specify configuration file
EndOfHelp
}


