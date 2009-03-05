#!/usr/bin/perl 
# $Id$
# Copyright (c)2009 by Brian Manning

# script to crawl a website and return all of the pages that have text that
# matches a certain pattern

use strict;
use warnings;
use WWW::Mechanize;

my $mech = WWW::Mechanize->new( agent => 'Mozilla/4.0 (compatible; MSIE 7.0;
Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; Blargulator');
my $pattern = q(Horizon-001);

my $base_url = q(http://www.fm949sd.com);
my %done_links;
my %todo_links = ( qq($base_url/morning/index.aspx) => 1 );
my @found_pages;

while ( scalar(keys(%todo_links)) > 0 ) { 
    print scalar(keys(%todo_links)) . qq( links to search; ) 
        . scalar(keys(%done_links)) . qq( pages searched; image found on )
        . scalar(@found_pages) . qq| page(s)\n|;
    my $page_url = (keys(%todo_links))[0];
    if ( ! exists( $done_links{$page_url} ) ) {
        print qq(Done URLs are: \n - );
        print join(qq(\n - ), sort(keys(%done_links))) . qq(\n);  
        print qq(Fetching Page: $page_url\n);
        $mech->get(qq($page_url));
        $done_links{$page_url}++;
        delete($todo_links{$page_url});
        print qq(Deleted key '$page_url' from todo_links;\n\tthere are now )
            . scalar(keys(%todo_links)) . qq( links to search\n);
        my @page_links = $mech->links();
        # parse out the images
        #print qq(Page '$page_url' has the following images and links:\n);
        my $total_images = 0;
        foreach my $image ( $mech->images() ) {
            $total_images++;
            if ( $image->url() =~ /$pattern/ ) {
                print qq(FOUND $pattern - $page_url\n);
                push(@found_pages, $page_url);
                #print qq(Image: ) . $image->url() . qq(\n);
            } # if ( $image->url() =~ $pattern )
        } # foreach my $image ( $mech->images() )
        # parse out the next set of pages
        my $total_page_links = 0;
        foreach my $link (@page_links) {
            my $match_url = $link->url();
            next if ( $match_url =~ /^$/ );
            next if ( $match_url =~ /^http:\/\// );
            next if ( $match_url =~ /^https:\/\// );
            next if ( $match_url =~ /^javascript/ );
            next if ( $match_url =~ /^#top/ );
            next if ( $match_url =~ /^mailto/ );
            next if ( $match_url =~ /\.jpg$/ );
            if ( $match_url !~ /^\// ) { $match_url = q(/) . $match_url; }
            #print qq(Link: ') . $match_url . qq('\n);
            $todo_links{$base_url . $match_url}++; 
            $total_page_links++;
        } # foreach my $link (@page_links)
        print qq($page_url had $total_page_links links and )
            . qq($total_images images\n);
        sleep 3;
    } else {
        delete($todo_links{$page_url});
    } # if ( ! exists( $done_links{$page_url} ) )

} # while ( scalar(@links) > 0 ) 

print qq(Found the following pages with the match string '$pattern'\n);
foreach my $found_page (@found_pages) {
    print qq(\t$found_page\n);
}

