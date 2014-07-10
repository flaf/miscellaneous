#!/usr/bin/perl

# The shell launcher :
#
#  sp_check localhost/cgi/check_storage.pl .....
#                                          ^^^^^
#                                          Ici on met les options du check (*)
#
# Passer les tokens de (*) dans des variables POST
# une à une -d 'token1=xxxx' -d token2=yyy' etc.
# Le script perl récupère tout ça et le met dans un
# tableau @POST_ARGV.
#
# Suivant que @ARGV est vide ou non, fera un GetOptionsFromArray
# de @ARGV ou de @POST_ARGV.

use strict;
use warnings;
use 5.010;
use CGI;
use Getopt::Long qw(GetOptionsFromArray :config no_ignore_case);
use ShinkenPacks::SNMP;

# Default values for the options.
my %options = (
                'warning'  => 30,
                'critical' => 60,
                'string'   => 'léopard',
              );

my %syntax = (
               'warning|w=i'  => \$options{warning},
               'critical|c=i' => \$options{critical},
               'string|s=s'   => \$options{string},
             );

# Will be used instead of @ARGV.
my @ARGV_TOKENS;

if (not @ARGV) {
    # When @ARGV is empty, we assume it's a call via http.
    my $q = CGI->new;
    print $q->header(-expires => 'now', -charset=> 'utf-8');

    my $post_param;
    my $decoded_post_param;
    my $c;
    $c = 1;
    while (1) {
        $post_param = $q->param("token$c");
        last if not defined $post_param;
        say "Perl: token$c -> [$post_param]";
        push(@ARGV_TOKENS, $post_param);
        $c += 1;
    }
} else {
    # When @ARGV is not empty, it's a call from shell.
    # In this cas, @ARGV_TOKENS is a copy of @ARGV.
    @ARGV_TOKENS = @ARGV;
}

GetOptionsFromArray(\@ARGV_TOKENS, %syntax) or bad_syntax();

foreach my $key (keys %options) {
    say "$key: [$options{$key}]";
}


sub bad_syntax {
    say "Sorry, bad syntax options.";
    exit(ShinkenPacks::SNMP::CODE_UNKNOWN);
}


