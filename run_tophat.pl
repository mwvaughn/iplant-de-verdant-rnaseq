#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);

my $app = "/usr/local2/tophat-1.3.1.Linux_x86_64/tophat";
my $bowtie = "/usr/local2/bowtie-0.12.7/bowtie-build";

# Define worflow options
my ($query_file1, $query_file2, $database_path, $user_database_path, $annotation_path, $user_annotation_path, $null);

my $out_file = "accepted_hits.bam";
my $format = 'SE';

GetOptions( "query|query1|input=s" => \$query_file1,
			"query2=s" => \$query_file2,
			"database=s" => \$database_path,
			"user_database=s" => \$user_database_path,
			"samfile=s" => \$out_file );

# Allow over-ride of system-level database path with user
# May not need to do this going forward...
if (defined($user_database_path)) {
	$database_path = $user_database_path
}
			
# Grab any flags or options we don't recognize and pass them as plain text
# Need to filter out options that are handled by the GetOptions call
my @args_to_reject = qw(-xxxx);
my $TOPHAT_ARGS = join(" ", @ARGV);
# Force --keep-tmp to solve a file not found error
$TOPHAT_ARGS = $TOPHAT_ARGS . " --keep-tmp --zpacker /usr/local3/bin/pbzip2 ";

foreach my $a (@args_to_reject) {
	if ($TOPHAT_ARGS =~ /$a/) {
		report("Most TopHat arguments are legal for use with this script, but $a is not. Please omit it and submit again");
		exit 1;
	}
}

# Check for presence of second read file
if (defined($query_file2)) {
	$format = 'PE';
	report("Pair-end alignment requested");
}

=head 1
# Auto index
unless (-e "$database_path.bwt") {
	my $fsize = -s $database_path;
	my $algo = "is";
	# Switch to slower bwtsw algorithm for sequences estimated, based
	# on file size, to be larger than 1Gbase
	if (*$fsize > 1000000000) {
		$algo = "bwtsw";
	}
	report("Indexing using $algo");
	system("$app index -a $algo $database_path");
}

unless (-e "$database_path.bwt") {
	report("Indexing failure...");
	exit 1;
}


=cut
my $align_command = "export PATH=\$PATH:/usr/local2/bowtie-0.12.7/:/usr/local2/samtools-0.1.12a/:/usr/local3/tophat-1.3.2.Linux_x86_64/; $app $TOPHAT_ARGS $database_path $query_file1 $query_file2";

report("$align_command");
system("$align_command");
system("mv tophat_out/accepted_hits.* $out_file; mv tophat_out/*bed .; mv tophat_out/*.info .");

if (-e $out_file) {
	exit 0
} else {
	exit 1
}

sub report {
	
	my $text = shift;
	print STDERR $text, "\n";
	
}

