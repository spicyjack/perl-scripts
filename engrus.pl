#!/usr/local/bin/perl

# CGI for the dictionary lookup
# Stanislav Sinyagin http://sinyagin.pp.ru/
# Version: 25-FEB-2000


# Uncomment this if you use Russian Apache (http://apache.lexa.ru)
# Then the output is in KOI8 only.
# $russianApache = 1;


$|=1;

require "./read.dict.pl";
require "./cgi-lib.pl";

$ENV{'PATH'} .= ":/usr/local/bin";

###############################################################
#                     Parse the CGI input
###############################################################
&ReadParse(*input);
local $english = $input{'English'};
local $encoding = $input{'Encoding'};
$encoding = "koi8" unless $encoding;

local $selected{$encoding} = 'SELECTED';
$myURL = &MyURL();

###############################################################
#                  Print the head of the document and the form 
###############################################################

if( not $russianApache )
{
    %charsetName = ("koi8" => "KOI8-R",
		    "1251" => "WINDOWS-1251",
		    "866"  => "IBM866");

    printf("Content-type: text/html; charset=%s\n\n", $charsetName{$encoding});
}
else
{
    printf("Content-type: text/html\n\n");
    $encoding = "koi8";
}

print <<EOT;
<HTML><HEAD><TITLE>English-Russian Dictionary</TITLE>
	<link rel="shortcut icon" href="/other/favicon.ico" />
	<link rel="icon" href="/other/favicon.ico">
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<H1>English-Russian Dictionary</H1>
EOT


open(MOTD, "motd.html");
print $_ while <MOTD>;
close MOTD;

print <<EOT;
<FORM METHOD="GET" ACTION="$myURL">
Enter English words (at least 4 first letters):<BR>
<INPUT NAME="English" VALUE="$english" SIZE=40>
<INPUT TYPE="submit" VALUE="Submit">
<BR>
EOT

if( not $russianApache )
{
    print <<EOT;
Select code page:<BR>
<SELECT NAME="Encoding">
<OPTION VALUE="866" $selected{'866'}>DOS (866)
<OPTION VALUE="1251" $selected{'1251'}>Windows (1251)
<OPTION VALUE="koi8" $selected{'koi8'}>Unix (KOI8-R)
</SELECT>
EOT
}

print "</FORM>\n";

if( $encoding eq "866" )
{
    open( SAVEOUT, ">&STDOUT" );
    open( STDOUT, "| ./koi8to866" );
}
elsif( $encoding eq "1251" )
{
    open( SAVEOUT, ">&STDOUT" );
    open( STDOUT, "| ./koi8to1251" );                       
}
elsif( $encoding ne "koi8" )
{
    printf("Incorrect encoding: %s\n", $encoding);
    exit;
}

$english =~ s/\W+/ /g; # remove all non-word characters
$english =~ s/^\s+//; # remove the leading space

foreach $word ( split( /\s+/, $english ) )
{
    $found = 0;
    print "<HR><H2>Search results: <I>$word</I></H2>\n<DL>\n";

    my $handle = &OpenDictionaryFileHandle( $word );
    local @array;
    while( &ReadDictionaryEntry( $handle, *array ) )
    {
        if( $array[0] =~ s/(^|\s)($word)/$1\<B\>$2\<\/B\>/i )
        {
            $found = 1;
            print "<DT>", $array[0];
            foreach $str ( split( '\n', $array[1] ) )
            {
                print "<DD>", $str;
            }
        }
    }
    close( $handle ); 

    if( !$found )
    {
        print "Nothing found: <B>$word</B><BR>";
        push @cgiReport, "Word not found: $word";
    }
    print "</DL>\n";
}


print <<'EOT'
<HR>
<FONT SIZE=1>Copyright (C) 2000,
<A HREF="http://sinyagin.pp.ru/">Stanislav Sinyagin</A>
</FONT>
</BODY></HTML>
EOT
