#!/usr/bin/perl -w

# open the input file 
	if ( $ARGV[0] eq "" ) { 
		print "You must enter a filename with a list of MP3's.\n";
		print "Create this list using the following command:\n";
		print "find -name *.mp3 -print > output.txt\n";
		print "Exiting...\n";
		exit 1;
	}	
	
	open (IN, $ARGV[0]) || die "Can\'t open file $ARGV[0]: \n$!";
	$total_lines=0;

	if ($ARGV[1]) { $show = $ARGV[1]; }
	else {$show = "";}
	
# count the time it takes to process

	$start_time = time;
		
# loop till EOF, looking for teltale strings...
	while (<IN>) { # read a line from the input file
		$_ =~ s/ /\\ /g;
		$_ =~ s/\(/\\\(/g;
		$_ =~ s/\)/\\\)/g;
		$_ =~ s/\,/\\\,/g;
		$_ =~ s/\&/\\\&/g;
		$_ =~ s/\'/\\\'/g;
#		$_ =~ s/\\/\\\\/g;

#		chop ($_);
#		chop ($_);


		if ($show eq "show") {
			system("id3 -l $_");
			if ($total_lines % 5 == 0 and $total_lines != 0) {
				print "Line $total_lines; Press any key to continue";
				$answer = <STDIN>;
			}
		}	
		elsif ($show eq "verbose") {
			print "Showing $_\n";
			system("id3 -l $_");
		}
		else {
			system("id3 -c  \"SpicyJack's Stash, (R)2000\" $_");	
		}
	# update total files changed
		$total_lines++;
	}

# tell'em how we did...
	$total_time=time - $start_time;
	$total_min = $total_time /60;
	print "Processed $total_lines lines\n";
	print "in $total_time seconds, or $total_min minutes.\n";
