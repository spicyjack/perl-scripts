#!/usr/bin/env perl
# vim: expandtab shiftwidth=2 tabstop=2
use Mojolicious::Lite;
use Mojo::Util qw(dumper);

# You can use `cURL` to make the HTTP POST request
# - Put your content in a file called 'data.txt'
# - Call `cURL` with
#
# curl -i -X POST -F 528d3604356050ce3ee5776aca7a9098=@large_image.jpg \
# http://localhost:3000/images/upload/54321/528d3604356050ce3ee5776aca7a9098;
# echo

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

  #my $upload = Mojo::Upload->new();
  my $log = Mojo::Log->new();

  $log->debug(dumper($c->req->content));
  my $upload = $c->req->upload($checksum);
  if ( defined $upload ) {
    $log->debug(q(Upload filename is: ) . $upload->filename);
    my $filename = $upload->filename;
    $log->debug(qq(Moving file $filename to /tmp));
    $upload->move_to(qq(/tmp/$ro_number.$filename));
    $c->render(
      status => 201,
      text => qq({ "upload_successful": "$ro_number/$checksum" })
    );
  } else {
    $c->render(
      status => 500,
      text => qq({ "upload_failed": "$ro_number/$checksum" })
    );
  }
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
