#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;


my $bibtex_file = "/home/ihrke/work/bib/dummy.bib";

sub import {
    hook(type => "preprocess", id => "bibtex", call => \&bibtex_preprocess);
}


sub bibtex_preprocess {
    my %params=@_;
	 print ">> bibtex.pm: $bibtex_file\n";
	 print ">> bibtex.pm: parameters '" . %params . "'\n";

	 my $k;
	 my $v;
	 while ( ($k,$v) = each %params ) { print "$k => $v\n"; }
    open(my $in,  "<",  $bibtex_file )  or die "Can't open $bibtex_file: $!";
	 my @lines = <$in>;
	 close $in or die "$in: $!";

	 my $content = join("",@lines);
#	 print $content;

	 my $key=$params{"key"};
	 my $entry="";
	 print "key=$key\n";
	 if ($content =~ /(@\w+{\s*$key.*?}(?=\s*@))/s ){
		  $entry=$1;
	 }
		
    return "<pre id='bibtex'>".$entry."</pre>";
}


1
