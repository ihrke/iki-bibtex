#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

use Text::BibTeX;
use Text::Format;

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
	 bibtex_default_output_format =>{
		  type => "string",
		  safe=>1,
		  description=> "output format for the bibtex-entry",
		  example => "raw,citation",
		  rebuild => 1,
	 },
}
sub bibtex_preprocess {
    my %params=@_;
	 my $bibtex_file="";
	 my $output_format="raw";
	 if( exists $config{bibtex_file} ){
		  $bibtex_file=$config{bibtex_file};
	 } 
	 if( exists $config{bibtex_default_output_format} ){
		  $output_format=$config{bibtex_default_output_format};
	 } 

	 # overwrite with file parameter
	 if( exists $params{file} ){
		  $bibtex_file=$params{file};
	 }
	 if( exists $params{format} ){
		  $output_format=$params{format};
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

	 my $output="";
	 if( $output_format eq "citation"){

	 } else {
		  $output="<div id='bibtex_entry'>".$found->print_s."</div>";
	 }

	 
#	 my $formatter=Text::Format->new( );
#    return "<pre id='bibtex'>".$formatter->format($found->print_s) ."</pre>";
	 return $output;
}


1
