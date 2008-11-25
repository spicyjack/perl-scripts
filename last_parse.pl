#!/usr/bin/perl

=pod

=head1 NAME

B<last_parse.pl> - parse the output of C<last -a -d>

=head1 DESCRIPTION

This should print out some text when called with C<pod2usage> from
L<Pod::Usage>.

=cut

use strict;
use warnings;
use Parse::RecDescent;

#$::RD_TRACE = 1;
$::RD_HINT = 1;

my $parser = Parse::RecDescent->new(<<'EOG' 
    # startup action
    { my $returned_text; }

    wtmp : session(s) { $return = \$returned_text }
        | logged_in(s) { $return = \$returned_text }
        | reboot(s) { $return = \$returned_text } 
        | down(s) { $return = \$returned_text }

    session : login_name pseudoterm day_of_week month date 
        login_time dash logout_time session_total login_host

    logged_in : login_name pseudoterm day_of_week month date 
        login_time still_logged_in_text login_host

    reboot : reboot_text system_boot_text day_of_week month date 
        login_time dash down_text session_total login_host

    down : login_name pseudoterm day_of_week month date 
        login_time dash down_text session_total login_host

    # simple rules that don't need any regexes
    dash : /-/
    still_logged_in_text : /still logged in/
    down_text : /down/
    reboot_text : /reboot/
    system_boot_text : /system boot/

    # more complext rules that need regexes
    login_name : /^\w+/
        { $returned_text = $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    #pseudoterm : /^\w+\/\d/ | /system boot/
    pseudoterm : /^\w+\/\d/ 
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    day_of_week: /\w+/ 
        { $returned_text .= '|' . $item[1]; 
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    month: /\w+/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    date: /\d+/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    login_time: /\d\d:\d\d/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    logout_time: /\d\d:\d\d/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    session_total: /\(\d+?\+?\d+:\d+\)/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

    login_host: /\d+\.\d+\.\d+\.\d+/
        { $returned_text .= '|' . $item[1];
          print $item[0] . q( -> ) . $item[1] . "\n"}
#        { push(@returned_text, $item[1]); }

EOG
) or die q(ERROR: bad Parse::RecDescent grammar);

#my $text = do { local $/; <> };

#$parser->wtmp($text) or print qq(No wtmp records found\n);
foreach my $line ( <STDIN> ) {
    $line =~ s/\s+/ /g;
    print q(=-) x 30 . qq(=\n);
    print qq(line is: $line\n);
    my $parser_return = $parser->wtmp($line);
    if ( ! defined $parser_return ) {
        print qq(line did not match\n);
    } else {
        my $return = $$parser_return;
        print qq(Parsed line: ) . $return . qq(\n);
    } # if ( ! defined $parser_return )
} # foreach my $line ( <STDIN> )

