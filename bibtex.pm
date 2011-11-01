#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

use Text::BibTeX;
#use Text::Format;

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
		  next if $entry->metatype ne BTE_REGULAR;
		  if ( $entry->key eq $key ){
				$found=$entry;
		  }
   }
	 unless(defined $found){
		  error("key $key not in file $bibtex_file\n");
	 }

	 my $output="";
	 if( $output_format eq "citation"){
		  $output=format_citation( $found );
	 } else {
		  $output="<pre id='bibtex_entry'>".$found->print_s."</pre>";
	 }

	 
#	 my $formatter=Text::Format->new( );
#    return "<pre id='bibtex'>".$formatter->format($found->print_s) ."</pre>";
	 return $output;
}

sub format_citation() {
	 my $entry=shift;
	 my $output;

	 
	 my @names = $entry->names ('author');
	 my @lasts;
	 foreach( @names ){
		  push( @lasts, ($_->part('last'))[0] );
	 }
	 $output=join(",", @lasts ).". ";

	 my $title;
	 my $journal;
	 my $publisher;
	 my $year;
	 ($title,$year,$journal,$publisher)=$entry->get('title','year',
																	'journal','publisher');
	 if( defined $year ){
		  $output=$output."($year): ";
	 }
	 
	 if( defined $title ){
		  $output=$output."**$title.**";
	 }
	 if( defined $journal ){
		  $output=$output."*$journal.*";
	 }
	 if( defined $publisher ){
		  $output=$output."*$publisher.*";
	 }

	 my $volume;
	 my $number;
	 my $pages;
	 ($volume,$number,$pages)=$entry->get('volume','number','pages');
	 if( defined $volume ){
		  $output=$output."$volume";
	 }
	 if( defined $number ){
		  $output=$output."($number)";
	 }
	 if( defined $pages ){
		  $output=$output.", $pages";
	 }
	 
	 return $output.".";
}


1
