#!/usr/bin/perl
package IkiWiki::Plugin::bibtex;
use warnings;
use strict;
use IkiWiki 3.00;

sub import {
    hook(type => "preprocess", id => "bibtex", call => \&bibtex_preprocess);
}


sub preprocess {
    my %params=@_;
    return 1;
}


1
