package ShinkenPacks::SNMP;

use strict;
use warnings;
use 5.010;
use Getopt::Long qw(:config no_ignore_case);
use Net::SNMP;
use CGI;

use constant {
    CODE_OK       => 0,
    CODE_WARNING  => 1,
    CODE_CRITICAL => 2,
    CODE_UNKNOWN  => 3,
};

#my $q = CGI->new;
#print $q->header(-expires => 'now', -charset=> 'utf-8');


1;


