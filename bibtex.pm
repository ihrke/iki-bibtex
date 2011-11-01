#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

use Text::BibTeX;

sub import {
    hook(type => "getsetup", id => "bibtex", call => \&getsetup);
    hook(type => "preprocess", id => "bibtex", call => \&bibtex_preprocess);

}

sub getsetup () {
    return 
		  plugin => {
            description => "Include bibtex in ikiwiki",
            safe => 1,
            rebuild => 1,
            section => "misc",
	 },
	 bibtex_file => {
		  type => "string",
		  safe=>1,
		  description=> "bibtex-file to use",
		  example => "/home/user/test.bib",
		  rebuild => 1,
	 },
}
sub bibtex_preprocess {
    my %params=@_;
	 my $bibtex_file="";
	 if( exists $config{bibtex_file} ){
		  $bibtex_file=$config{bibtex_file};
	 } 

	 # overwrite with file parameter
	 if( exists $params{file} ){
		  $bibtex_file=$params{file};
	 }
	 unless( -e $bibtex_file ){
		  error("bibtex-file $bibtex_file doesn't exist\n");
	 }
	 my $key;
	 if( exists $params{key} ){
		  $key=$params{key};
	 } else {
		  error( "no key given");
	 }

	 debug(">> bibtex.pm: $bibtex_file\n");
	 debug(">> bibtex.pm: $key\n");

	 my $bibfile = new Text::BibTeX::File $bibtex_file;
	 my $entry;
	 my $found;
	 while ($entry = new Text::BibTeX::Entry $bibfile)
	 {
		  next unless $entry->parse_ok;
		  
		  if ( $entry->key eq $key ){
				$found=$entry;
				print $entry->print_s;
		  }
   }
	 unless(defined $found){
		  error("key $key not in file $bibtex_file\n");
	 }

    return "[[!toggle id='$key' text='$key']]".$found->print_s ."";
}


1
