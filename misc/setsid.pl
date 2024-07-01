#!/usr/bin/perl -w
use strict;
use POSIX qw(setsid);
fork() && exit(0);
setsid() or die "setsid failed: $!";
exec @ARGV;
