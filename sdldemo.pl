#!/opt/local/bin/perl

use SDL;
use SDL::App;

    $app = SDL::App->new(-flags => $sdl_flags | ($fullscreen ? SDL_FULLSCREEN :
    0), -title => 'Frozen-Bubble', -width => 640, -height => 480);
