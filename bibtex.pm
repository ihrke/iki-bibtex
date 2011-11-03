#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

use Text::BibTeX;
#use Text::Format;

my %bibtex_keys; # holds key=>file pairs

sub import {
    hook(type => "getsetup", id => "bibtex", call => \&getsetup);
    hook(type => "preprocess", id => "bibtex", call => \&bibtex_preprocess);
    hook(type => "preprocess", id => "bibtex_bibliography", call => \&bibliography_preprocess);
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
		  example => "cite,raw,citation",
		  rebuild => 1,
	 },
}


sub get_bibtex_entry_from_file {
	 my $file=shift;
	 my $key=shift;

	 Text::BibTeX::delete_all_macros();
	 my $bibfile = new Text::BibTeX::File $file;
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
		  error("key $key not in file $file\n");
	 }

	 return $found;
}

sub bibtex_preprocess {
    my %params=@_;
	 my $bibtex_file="";
	 my $output_format="citation";
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

	 my $entry = get_bibtex_entry_from_file( $bibtex_file, $key );

	 my $output="";
	 if( $output_format eq "citation"){
		  $output=format_citation( $entry );
	 } elsif ( $output_format eq "cite"){
		  $output=format_cite( $entry );
	 } else {
		  $output="<pre id='bibtex_entry'>".$entry->print_s."</pre>";
	 }

	 $bibtex_keys{$key}=$bibtex_file;
#	 my $formatter=Text::Format->new( );
#    return "<pre id='bibtex'>".$formatter->format($found->print_s) ."</pre>";
	 return $output;
}

sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}


sub bibliography_preprocess {
    my %params=@_;

	 my $entry;
	 my $output;
	 foreach( keys %bibtex_keys ){
		  $entry=get_bibtex_entry_from_file( $bibtex_keys{ $_ }, $_ );
		  $output .= "* ".format_citation( $entry )."\n";
	 }

	 return $output;
}



## formatting
##-----------------
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
		  $output=$output."**$title.** ";
	 }
	 if( defined $journal ){
		  $output=$output."*$journal.* ";
	 }
	 if( defined $publisher ){
		  $output=$output."*$publisher.* ";
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

## Author (Year) output
sub format_cite() {
	 my $entry=shift;
	 my $output;

	 my @names = $entry->names ('author');
	 my @lasts;
	 foreach( @names ){
		  push( @lasts, ($_->part('last'))[0] );
		  if( $lasts[$#lasts] =~ /{(.*)/ ){
				$lasts[$#lasts] = $1;
		  }
	 }
	 $output=join(",", @lasts )." ";

	 my $year;
	 $year=$entry->get('year');
	 if( defined $year ){
		  $output=$output."($year)";
	 }
	 return $output;
}


1
