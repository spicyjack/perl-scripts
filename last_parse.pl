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

# for debugging
# traces parsing
#$::RD_TRACE = 1;
# adds more debug output if an eror occurs
$::RD_HINT = 1;
my @parsed_text; 

my $parser = Parse::RecDescent->new(<<'EOG' 
    # startup action

    wtmp_line : session(s)
        | logged_in(s)
        | reboot(s) 
        | down(s) 
        | wtmp_begins

    session : login_name pseudoterm day_of_week month_name month_date 
        login_time dash logout_time session_total login_host

    logged_in : login_name pseudoterm day_of_week month_name month_date 
        login_time still_logged_in_text login_host

    reboot : reboot_text system_boot_text day_of_week month_name month_date 
        login_time dash down_text session_total login_host

    down : login_name pseudoterm day_of_week month_name month_date 
        login_time dash down_text session_total login_host

    wtmp_begins : wtmp_begins_text day_of_week month_name month_date 
        hh_mm_ss_yy

    # simple rules that don't need any regexes
    wtmp_begins_text : /wtmp begins/
    dash : /-/
    still_logged_in_text : /still logged in/
    down_text : /down/
    reboot_text : /reboot/
    system_boot_text : /system boot/

    # rules used by other rules
    hh_mm : /\d\d:\d\d/ 

    # more complex rules that need regexes and return things
    hh_mm_ss_yy : /\d\d:\d\d:\d\d \d\d\d\d/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    login_name : /^\w+/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    #pseudoterm : /^\w+\/\d/ | /system boot/
    pseudoterm : /^\w+\/\d+/ 
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    day_of_week: /\w+/ 
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    month_name: /\w+/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    month_date: /\d+/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    login_time: hh_mm
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    logout_time: hh_mm
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    session_total: /\(\d+?\+?\d+:\d+\)/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

    login_host: /\d+\.\d+\.\d+\.\d+/
        {   push(@::parsed_text, $item[1]); 
            print $item[0] . " -> " .  $item[1] . "\n";}
#        { push(@::parsed_text, $item[1]); }

EOG
) or die q(ERROR: bad Parse::RecDescent grammar);

foreach my $line ( <STDIN> ) {
    $line =~ s/\s+/ /g;
    print q(=-) x 35 . qq(=\n);
    print qq(line is: $line\n);
    if ( defined $parser->wtmp_line($line) ) {
        print qq(Parsed line: ) . join(q(|), @parsed_text) . qq(\n);
    } else {
        print qq(line did not match\n);
    } # if ( ! defined $parser_return )
    @parsed_text = ();
} # foreach my $line ( <STDIN> )

