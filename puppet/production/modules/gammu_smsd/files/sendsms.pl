#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use CGI;

my $q = CGI->new;
print $q->header(-expires => 'now',);

my $phone = $q->param('phone');
my $msg = $q->param('msg');

if ((not defined $phone) or (not defined $msg)) {
    say "Sorry, you must define these POST variables: phone, msg.";
    exit 0;
}

if (not $phone =~ /^[0-9]{10}$/) {
    say "Sorry, your phone number is invalid.";
    exit 0;
}

# Truncate message to 160 characters.
$msg = substr($msg, 0, 160);

#say $phone;
#say $msg;

system("/usr/bin/gammu-smsd-inject", "TEXT", $phone, "-text", $msg);

if ($? == -1) {
    # Bad system call.
    say "Command failed: $!"
}
else {
    # Good system call.
    my $return_value = $? >> 8;
    if ($return_value == 0) {
        say "OK";
    } else {
        say "Problem, `gammu-smsd-inject' exited with value $return_value.";
    }
}

