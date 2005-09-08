#!/usr/bin/perl
srand(time() ^($$ + ($$ <<15))) ;
for ($x=0;$x<10;$x++) {
print rand() . "\n";
}
