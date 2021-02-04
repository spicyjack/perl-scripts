#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Time::HiRes qw( gettimeofday tv_interval );

   my $start_time = [gettimeofday];

   sleep 2;
   my $elapsed_time = tv_interval( $start_time );
   say qq(Elapsed time: $elapsed_time);
   my $run_mins = 0;
   my $run_seconds = 0;
   if ( $elapsed_time > 60 ) {
      my $run_mins = $elapsed_time / 60;
      my $minute_seconds = $run_mins * 60;
      $run_seconds = $elapsed_time - $minute_seconds;
   } else {
      $run_seconds = $elapsed_time;
   }

   warn sprintf(qq(Script runtime: %um %0.2fs\n), $run_mins, $run_seconds);
