#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(:config pass_through);

#cuffdiff [options]* <transcripts.gtf> <sample1_replicate1.sam[,...,sample1_replicateM]> <sample2_replicate1.sam[,...,sample2_replicateM.sam]>... [sampleN.sam_replicate1.sam[,...,sample2_replicateM.sam]]

my $labels = 'cuffdiff';
my $num_threads = 6;
my $time_series = 0;
my $upper_quartile_norm = 0;
my $total_hits_norm = 0;
my $compatible_hits_norm = 1;
my $frag_bias_correct = '';
my $multi_read_correct = 0;
my $min_alignment_count = 10;
my $mask_file = '';
my $fdr = '0.05';
my $cannedReference = '';

my $result = GetOptions ( 'labels:s' => \$labels,
						  'num-threads=i' => \$num_threads,
						  'time-series' => \$time_series,
						  'upper-quartile-norm' => \$upper_quartile_norm,
						  'total-hits-norm' => \$total_hits_norm,
						  'compatible-hits-norm' => \$compatible_hits_norm,
						  'frag-bias-correct:s' => \$frag_bias_correct,
						  'multi-read-correct' => \$multi_read_correct,
						  'min-alignment-count=i' => \$min_alignment_count,
						  'mask-file:s' => \$mask_file,
						  'FDR:s' => \$fdr,
						  'cannedReference=s' => \$cannedReference	);

my $cmd = "/usr/local2/bin/cuffdiff --num-threads $num_threads --min-alignment-count $min_alignment_count --FDR $fdr ";

if ($labels ne '') {
	$cmd .= "--labels $labels ";
}

if ($frag_bias_correct ne '') {
	$cmd .= "--frag-bias-correct $frag_bias_correct ";
}

if ($mask_file ne '') {
	$cmd .= "--mask-file $mask_file ";
}

if ($time_series) {
	$cmd .= "--time-series "
}
if ($upper_quartile_norm) {
	$cmd .= "--upper-quartile-norm "
}
if ($total_hits_norm) {
	$cmd .= "--total-hits-norm "
}
if ($compatible_hits_norm) {
	$cmd .= "--compatible-hits-norm "
}
if ($multi_read_correct) {
	$cmd .= "--multi-read-correct "
}

# Append GTF file
$cmd .= "$cannedReference ";

# Workaround for broken multi-file behavior in Workflow class
#my $files = shift @ARGV;
#$files =~ s/'//gm;
#$files =~ s/\s+/\ /gm;

# @ARGV should contain only files now 
my $files = join(" ", @ARGV);

# Stuff file names onto end of command string
$cmd .= $files;

print STDERR $cmd, "\n";

system($cmd);
