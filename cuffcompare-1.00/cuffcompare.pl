#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(:config pass_through);

#cuffcompare [options]* <cuff1.gtf> [cuff2.gtf] ... [cuffN.gtf]

my $cannedReference = '';
my $userReference = '';
my $doRestrict = 0;
my $doContained = 0;
my $output = 'cuffcompare';

my $result = GetOptions ( 'cannedReference:s' => \$cannedReference,
						  'userReference:s' => \$userReference,
						  'R' => \$doRestrict,
						  'C' => \$doContained,
						  'o:s' => \$output );

my $cmd = "/usr/local2/bin/cuffcompare ";

if ($doRestrict) {	$cmd .= "-R " }
if ($doContained) {	$cmd .= "-C " }

if (($cannedReference ne '') and ($userReference ne '')) {
	die "You may not specify both a pre-defined reference annotation and a custom GTF file"
}

if ($cannedReference ne '') {
	$cmd .= "-r $cannedReference ";
} elsif ($userReference ne '') {
	$cmd .= "-r $userReference ";
}

my $files = shift @ARGV;

$files =~ s/'//gm;
$files =~ s/\s+/\ /gm;

$cmd .= $files;

print STDERR $cmd, "\n";

system($cmd);

