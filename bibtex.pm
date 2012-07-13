#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

use Text::BibTeX;
use Data::Dumper;

#use Text::Format;

my %bibtex_keys; # holds page=>[ key=>file, ... ]

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
	 bibtex_link_entry => {
		  type => "string",
		  safe=>1,
		  description => "url to link to with cite-commands ([[file]] and [[key]] substituted)",
		  example => "http://myhost.org/script?file=[[file]]&key=[[key]]",
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
	 my $page=$params{destpage}; # this is the current page
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
	 $bibtex_file = IkiWiki::srcfile($bibtex_file) if ( ! -e $bibtex_file );
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

	 $bibtex_keys{$page}{$key}=$bibtex_file;

	 return $output;
}

sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}


sub bibliography_preprocess {
    my %params=@_;
	 my $page=$params{'page'};

	 my $entry;
	 my $output;


	 foreach( keys %{ $bibtex_keys{$page} } ){
		  $entry=get_bibtex_entry_from_file( $bibtex_keys{$page}{ $_ }, $_ );
		  $output .= "* ".format_citation( $entry )."\n";
	 }

	 return $output;
}



## formatting
##-----------------
sub format_citation() {
	 my $entry=shift;
	 my $output;
	 my $link=""; 
	 if( exists $config{bibtex_link_entry} ){
		  $link=$config{bibtex_link_entry};
	 }

	 
	 my @names = $entry->names ('author');
	 if( !@names ){
		  @names = $entry->names ('editor');
	 }

	 my @lasts;
	 foreach( @names ){
		  push( @lasts, ($_->part('last'))[0] );
		  if( $lasts[$#lasts] =~ /{(.*)}/ ){
				$lasts[$#lasts] = $1;
		  }
	 }
	 $output=join(", ", @lasts ).". ";

	 my $title;
	 my $journal;
	 my $publisher;
	 my $year;
	 ($title,$year,$journal,$publisher)=$entry->get('title','year',
																	'journal','publisher');
	 if( defined $year ){
		  $output=$output."($year): ";
	 }
	 
	 if( $link ne "" ){
		  my $key=$entry->key;
		  $link =~ s/\[\[file\]\]/$config{bibtex_file}/;
		  $link =~ s/\[\[key\]\]/$key/;
		  $output = "[".$output."](".$link.")";
	 }

	 

	 if( defined $title ){
		  if( $title =~ /{(.*)}/ ){
				$title = $1;
		  }
		  if( $title =~ /(.*)\.$/ ){
				$title = $1;
		  }
		  $output=$output."**$title.** ";
	 }
	 if( defined $journal ){
		  $output=$output."*$journal.* ";
		  if( $journal =~ /(.*)\.$/ ){
				$journal = $1;
		  }
	 }
	 if( defined $publisher ){
		  if( $publisher =~ /(.*)\.$/ ){
				$publisher = $1;
		  }
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
		  if( defined $number || defined $volume ){
				$output.=", ";
		  }
		  $output.=$pages;
	 }
	 if( $output =~ /.*\.\s*$/ ){
		  return $output;
	 } else {
		  return $output.".";
	 }
}

## Author (Year) output
sub format_cite() {
	 my $entry=shift;
	 my $output;
	 my $link=""; 
	 if( exists $config{bibtex_link_entry} ){
		  $link=$config{bibtex_link_entry};
	 }

	 my @names = $entry->names ('author');
	 if( !@names ){
		  @names = $entry->names ('editor');
	 }

	 my @lasts;
	 foreach( @names ){
		  push( @lasts, ($_->part('last'))[0] );
		  if( $lasts[$#lasts] =~ /{(.*)}/ ){
				$lasts[$#lasts] = $1;
		  }
	 }
	 $output=join(", ", @lasts )." ";

	 my $year;
	 $year=$entry->get('year');
	 if( defined $year ){
		  $output=$output."($year)";
	 }

	 if( $link ne "" ){
		  my $key=$entry->key;
		  $link =~ s/\[\[file\]\]/$config{bibtex_file}/;
		  $link =~ s/\[\[key\]\]/$key/;
		  $output = "[".$output."](".$link.")";
	 }

	 return $output;
}


1
