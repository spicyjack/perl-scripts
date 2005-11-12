#!/usr/bin/perl
  
  use X11::Protocol;
  use IO::Select;
  
  my $x = X11::Protocol->new();
  
  sub res { $x->new_rsrc() };
  
  my $eventmask = $x->pack_event_mask(qw(KeyPress Exposure ButtonPress ButtonRelease PointerMotion));
  
  $x->CreateWindow(my $win = res(), $x->root, 'InputOutput', $x->root_depth,
                   'CopyFromParent', 0, 0, 600, 400, 1,
                   'background_pixel' => $x->white_pixel,
                   'event_mask' => $eventmask,
  );
  
  $x->ChangeProperty($win, $x->atom("WM_NAME"), $x->atom("STRING"), 8, 'Replace', 'Perl Paint');
  
  $x->MapWindow($win);
  
  $x->event_handler(do {
  
    my @lastxy;
    my $buttonpressed = 0;
  
    $x->CreateGC(my $black = res(), $win, 'foreground' => $x->black_pixel, 'graphics_exposures' => 0);
    $x->CreateGC(my $white = res(), $win, 'foreground' => $x->white_pixel, 'graphics_exposures' => 0);
  
    sub {
  
      my %e = @_;
  
      if($e{name} eq 'MotionNotify') {
  
        $x->PolyLine($win, $black, 'Origin', @lastxy, $e{event_x}, $e{event_y})
               if $lastxy[0] and $lastxy[1] and $buttonpressed;
    
        @lastxy = ($e{event_x}, $e{event_y});
    
      } elsif ($e{name} eq 'ButtonPress') {
  
        @lastxy = ($e{event_x}, $e{event_y});
        $buttonpressed = 1; 
  
      } elsif ($e{name} eq 'ButtonRelease') {
  
        $buttonpressed = 0;
    
      } elsif ($e{name} eq 'Expose') {
    
        $x->PolyRectangle($win, $white, [($e{'x'}, $e{'y'}), $e{width},
             $e{height}]);
      }
  
    };
  
  });
  
  my $sel = IO::Select->new($x->connection->fh);
  
  while(1) {
    for my $fh ($sel->can_read) {
      $x->handle_input if $fh == $x->connection->fh;
    }
  }
