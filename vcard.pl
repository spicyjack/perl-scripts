#!/usr/bin/perl
#Usage:  vcard.pl -?
#Version: 1.2
#Fixes:
#Clear array for batch sends
#Added "-p" options

use Getopt::Std;
use CGI qw(:all *table);
use CGI::Carp qw(fatalsToBrowser);

my(%opts);
getopts('f:i:t:m:sp?h',\%opts);

#Set the following to "1" if you want to send mail, otherwise, set to "0" and just the code will be printed out.
$SENDMAIL=$opts{'s'} || 1;

#Set the following to the mail server
$MAILHOST=$opts{'m'} || 'localhost';

#Set the following to the username on the mail server
$FROM=$opts{'f'} || 'brian';

#Set the following to a CSV list of addresses to send the mail to
$TO=$opts{'t'} || param('to') || '8586991658@mobile.att.net';
$TO=~/.*?([\w\@\.\-]+).*?/;
$TO=$1;

#Uncomment the following to use Blat for your MTA (If you are on a Windows machine)
#Set the following to the location of your mail program, Blat (www.blat.net)
#$BLAT="C:\\blat";
#$MAILCOMMAND="|$BLAT - -server $MAILHOST -f $FROM -s \"\" -t $TO -q";

#uncomment the following to use Sendmail for your MTA (If you are on a Unix machine)
#Set the following to your sendmail location
$SENDMAILPATH="/usr/sbin/sendmail -f$FROM -v";
$MAILCOMMAND="| $SENDMAILPATH $TO";

#Set the following to the number of seconds to sleep between consecutive sends when a file is used
#This is very important because if you flood your phone it may be down for a day or longer before you
#can receive messages again.  I recommend 30 or higher.  Hey, it's better than typing them all in again.
#I've added the "-p" option to prompt before sending each card.
$SLEEPTIME="30";


#You are done editing

if($opts{'?'} or $opts{'h'}){
  &usage();
}

if($opts{'i'}){
  open(DAT,"<$opts{'i'}") or die "Can't open $opts{'i'}: $!";
}

$continue=1;

while($continue){
  if($opts{'i'}){
    if(eof(DAT)){close(DAT);exit;}
    sleep($SLEEPTIME) if !$opts{'p'};
    chomp($data=<DAT>);
    ($name,$number,$email)=split(/\s*\t\s*/,$data);
    if($opts{'p'}){
      print "Send: $name, $number, $email (Y/n)>";
      chomp($in=<STDIN>);
      next if $in=~/^n/i;
    }
  }
  else{
    if(!$ENV{'HTTP_USER_AGENT'}){
      print "\nEnter Name (CTRL+C to quit): ";
      chomp($name=<STDIN>);
      print "Enter Number: ";
      chomp($number=<STDIN>);
      print "Enter Email: ";
      chomp($email=<STDIN>);
    }
    else{
      if(param(todo) eq 'Send'){
        $name=param('name');
        $number=param('number');
        $email=param('email');
        $TO="";
	$TO=param('to');# if param('to');
	   print header(), "Sending to $TO ....",br(),"<pre>\n";
      }
      else{
        print header(),
			h1('The Cell Phone VCard Mailer'),
			"This code is known to work with: ",
			br(),
			"&nbsp;",
			i(b("Providers:"),"AT&T (\@mobile.att.net), US Cellular (\@uscc.textmsg.com)."),
			" ",
			br(),
			"&nbsp;",
			i(b("Phones:"),u("Nokia:")," 5160, 5165, 6160, 6165, 8260"),
			p(),
			start_form({-name=>'vcard'}),
			b("Enter Your Cell Phone Email Address:"),
			" ",
			textfield({-name=>'to'}),
			br(),
			b("Enter Name on Business Card:"),
			" ",
			textfield({-name=>'name'}),
			br(),

			b("Enter Phone Number on Business Card :"),
			" ",
			textfield({-name=>'number'}),
			br(),
			b("Enter Email Address on Business Card:"),
			" ",
			textfield({-name=>'email'}),
			br(),
			reset(),
			" ",
			submit({-name=>'todo',-value=>'Send'}),
			end_form(),
			p(),
			a({-href=>"mailto:bsa\@pobox.com,%61%64%61%6d%40%62%75%6d%70%2e%75%73?subject=VCard Comments"},i("E-Mail Comments about VCard")),
			p(),
			"Written by: ",
			a({-href=>"mailto:bsa\@pobox.com"},"Brad Andersen"),
			" and ",
			a({-href=>"mailto:%61%64%61%6d%40%62%75%6d%70%2e%75%73"},"Adam Bumpus");
        exit;
      }
    }
  }
  $number=~s/[+-]//sgi;

  $string="BEGIN:VCARD\r\n";
  $string.="N:$name\r\n" if $name;
  $string.="TEL:$number\r\n" if $number;
  $string.="EMAIL:$email\r\n" if $email;
  $string.="END:VCARD\r\n";
  print "\nGenerating VCard:\n$string\n";


#My limit for text messages is 150 char, this leaves me with room for return address and such

  #Generate a random number to use for message id
  $ID=rand(255);

  #Convert the VCard to Hex
  $vcard="";
#I've learned a new trick so I'm going to use it.  We use substr like splice.
#  for($i=0;$i<length($string);$i++){
#    $vcard.=sprintf("%2.2X",ord(substr($string,$i,1)));
#  }
  while(length($string)){
    $vcard.=sprintf("%2.2X",ord(substr($string,0,1,"")));
  }

  #break into chunks of 80 characters and store in an array
  @string=();
  while(length($vcard)>80){
    push(@string,substr($vcard,0,80,""));
  }
  push(@string,$vcard);

  #Process each 80 character chunk and send 95 character messages
  for($i=0;$i<scalar(@string);$i++){
    $message="//SCKL23F423F4";
    $message.=sprintf("%2.2X%2.2X%2.2X ", $ID ,scalar(@string),$i+1);
    $message.=$string[$i];

    print "\nThe Nokia Smart Messaging VCard is:\n\n$message\n";

    if($SENDMAIL==1){
      print "\nMailing output to $TO\n";
      open(OUT,"$MAILCOMMAND") or die "Can't open mailer: $!";
      print OUT "$message\n";
      close(OUT) if $SENDMAIL;
    }
  }
  if($ENV{'HTTP_USER_AGENT'}){
     print "\nSent.</pre>",
	p(),
	"Enter ",
	a({-href=>"javascript:history.go(-1)"},"another?"),;
     last;
  }
}
exit;

sub usage{
print <<END;
Usage: $0 [options]

Options		Description
-i filename		A tab delimited input file of "name[tab]phone number[tab]email address" to send
-p		Prompt before sending each card in "filename"
-t phone email	Email address of the phone you want to send the card to
-f from email	Valid email address on MTA server (From: address)
-m server		IP Address or Hostname of MTA server
-s			Send mail
-?			Print this message
-h			Print this message

(This can be run as a CGI program, if the To: field is left blank then the hard
  coded To: address will be used)

(Most of these can be hardcoded into this file)

END
exit;
}


