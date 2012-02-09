#!/usr/bin/perl

# print the contents to this script through the SyntaxHighlighter JavaScript
# library in order to demo it's functionality

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities;

my $q = CGI->new();

print $q->header(), 
    $q->start_html(-title => q(Syntax highlight demo)) 
    . qq(\n);

print <<EOJS;
<!-- Include required JS files -->
<!-- http://xregexp.com/ -->
<script type="text/javascript" src="/js/xregexp-min.js"></script>
<script type="text/javascript" src="/js/shCore.js"></script>
<link href="/css/shCore.css" rel="stylesheet" type="text/css" />
 
<!--
    At least one brush, here we choose JS. You need to include a brush for
    every language you want to highlight
-->
<script type="text/javascript" src="/js/shBrushJScript.js"></script>
<script type="text/javascript" src="/js/shBrushPerl.js"></script>

<!-- Include *at least* the core style and default theme -->
<link href="/css/shThemeDefault.css" rel="stylesheet" type="text/css" />
<link href="/css/shCoreDefault.css" rel="stylesheet" type="text/css" /> 

<!-- Tickle the SyntaxHighlighter object -->
<script type="text/javascript">SyntaxHighlighter.all()</script>
EOJS

print $q->h1(q(The source code of this CGI script, with syntax highlighting))
    . qq(\n);
# create a filehandle to read in the contents of this file
open(IN, q(<) . __FILE__);    
my @script_text = <IN>;
close(IN);
my $text = join(qq(), @script_text);
print q(<script type="syntaxhighlighter" class="brush: perl"><![CDATA[) 
    . qq(\n);
print encode_entities($text) . qq(\n);
print qq(]]></script>\n);

print $q->end_html();

exit 0;
