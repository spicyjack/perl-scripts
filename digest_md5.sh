perl -e 'use Digest::MD5; my $x = Digest::MD5->new; $x->add(q(spam, spam, and eggs)); print $x->b64digest . qq(\n);'
