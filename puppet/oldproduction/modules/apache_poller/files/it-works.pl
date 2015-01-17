#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use CGI;

my $q = CGI->new;
print $q->header(-charset=>'utf-8',-expires=>'now');

say "It works!";


