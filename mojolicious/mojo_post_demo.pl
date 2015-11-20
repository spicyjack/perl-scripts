#!/usr/bin/env perl
# vim: expandtab shiftwidth=2 tabstop=2
use Mojolicious::Lite;
use Mojo::Util qw(dumper);

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get q(/) => sub {
  my $c = shift;
  $c->render(template => 'index');
};

post q(/images/upload/:ro_number/:checksum) => sub {
  my $c = shift;
  my $ro_number = $c->stash(q(ro_number));
  my $checksum = $c->stash(q(checksum));
  #my $upload = $c->req->upload($checksum);
  #my $upload = Mojo::Upload->new();
  my $log = Mojo::Log->new();
  #$log->debug(q(Upload filename is: ) . $upload->filename);
  $log->debug(dumper($c));
  $c->render(
    status => 201,
    text => "upload_successful: $ro_number/$checksum"
  );
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to the Mojolicious real-time web framework!

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
