#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use CGI;

my $q = CGI->new;
print $q->header();

say "It works!";


