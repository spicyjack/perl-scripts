package Gtk2::Ex::Pod::Syntax::Highlighter;

use warnings;
use strict;

use Marek::Pod::HTML;
use Text::VimColor;
@ISA = qw(Marek::Pod::HTML);

=head1 NAME

Gtk2::Ex::Pod::Syntax::Highlighter - The great new Gtk2::Ex::Pod::Syntax::Highlighter!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

A subclass of L<Marek::Pod::HTML> that will apply VIM-style syntax
highlighting to verbatim POD blocks
(L<http://perldoc.perl.org/perlpod.html#Verbatim-Paragraph>).

    use Gtk2::Ex::Pod::Syntax::Highlighter;

    my $foo = Gtk2::Ex::Pod::Syntax::Highlighter->new();
    ...

=head1 EXPORT

No exports, this module is meant to be used as an object-oriented module.

=head1 METHODS

=head2 verbatim($text, $line_num, $pod_para)

Process a verbatim POD paragraph as parsed by L<Pod::Parser> and
L<Marek::Pod::HTML>.  See L<Pod::Parser> for a description of the arguments to
this method.

=cut

sub verbatim {
    my ($self, $paragraph, $line_num, $pod_para) = @_;

    $self->{_current_anchor} = '';
    # strip trailing whitespace
    $paragraph =~ s/[\s\n]+$//s;

    unless(length($paragraph)) {
        # just an empty line
        $self->{_current}->push_content(HTML::Element->new('p'), "\n");
    } elsif(!$self->{_begin}) {
        # a regular paragraph
        my $pre;
        my $content = $self->{_current}->content();
        # reuse last <pre> if immediate predecessor
        if(defined $content && ref($content) && @$content &&
         ref($content->[-2]) && $content->[-2]->tag() eq 'pre') {
          $pre = $content->[-2];
        } else {
          $pre = HTML::Element->new('pre', CLASS => 'POD_VERBATIM');
          $self->{_current}->push_content($pre,"\n");
        }
        $pre->push_content("\n");

        if($self->{_current_head1_title} eq 'NAME' && !$self->description()) {
            # save the description for further use in TOC
        my $str = $paragraph;
        $str =~ s/^[\n\s]+//;
            $self->description($str) if($str);
        } # if($self->{_current_head1_title} eq 'NAME' && !$self->description())
        # this is special in perl.pod
        foreach(split(/\n/,$paragraph)) {
            # TODO expand tabs correctly?
            if(s/^(\s+)([\w:]+)(\t+)//) {
                # this is for perl.pod - an implied list
                my ($indent,$page,$postdent) = ($1,$2,$3);
                my $dest = $self->{-cache}->find_page($page);
                if($dest) {
                    my $destfile = _construct_file_name(
                        $dest->page(), $self->depth(), $self->{-suffix});
                    my $link = HTML::Element->new('a', href => $destfile,
                        CLASS => 'POD_LINK');
                    $link->push_content($page);
                    $page = $link;
                }
                $pre->push_content($indent,$page,$postdent,$_,"\n");
            } else {
                $pre->push_content($_,"\n");
            } # if(s/^(\s+)([\w:]+)(\t+)//)
        } # foreach(split(/\n/,$paragraph))
    } elsif($self->{_begin} eq 'html') {
        # a "verbatim" =begin html paragraph
        $self->{_raw_html} .= $paragraph;
    } # unless(length($paragraph))

}

=head1 AUTHOR

Brian Manning, C<< <bmanning at qualcomm.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-gtk2-ex-pod-syntax-highlighter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gtk2-Ex-Pod-Syntax-Highlighter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gtk2::Ex::Pod::Syntax::Highlighter


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Gtk2-Ex-Pod-Syntax-Highlighter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Gtk2-Ex-Pod-Syntax-Highlighter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Gtk2-Ex-Pod-Syntax-Highlighter>

=item * Search CPAN

L<http://search.cpan.org/dist/Gtk2-Ex-Pod-Syntax-Highlighter>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Gtk2::Ex::Pod::Syntax::Highlighter
