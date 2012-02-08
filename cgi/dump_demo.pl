#!/usr/bin/perl

# print the contents to this script through the SyntaxHighlighter JavaScript
# library in order to demo it's functionality

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $q = CGI->new();

print $q->header(), 
    $q->start_html(-title => q(Syntax highlight demo)) 
    . qq(\n);

print $q->h1(q(The source code of this CGI script)) . qq(\n);
# create a filehandle to read in the contents of this file
open(IN, q(<) . __FILE__);    
my @script_text = <IN>;
close(IN);
my $text = join(qq(\n), @script_text);
print qq(<pre>$text</pre>\n);
print $q->end_html();

exit 0;
