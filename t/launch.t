#!/usr/bin/perl -w
use Test::More;
use strict;

BEGIN {
	plan tests => 17;
	use_ok('Mac::Apps::Launch');
}

use Mac::Apps::Launch 1.80;
use Mac::Processes;
use POSIX 'SIGTERM';

use MacPerl '$Version';

SKIP: {
	skip "Not MacPerl", 1 if $^O ne 'MacOS';
	$Version =~ /^(.+)\s+.*$/;
	cmp_ok($1, 'ge', '5.1.4r4', 'Check $MacPerl::Version');
}

my $target = 'MACS';
my @paths  = map { LSFindApplicationForInfo("", $_) } qw(
	com.apple.calculator
	com.apple.TextEdit
);

TODO: {
	local $TODO = "no Mac::Apps::Launch Hide/Show on Mac OS X" if $^O eq 'darwin';

	ok(Hide($target), 'Hide');
	ok(Show($target), 'Show');
}

SKIP: {
#	skip "Mac::Apps::Launch", 3;

	ok(IsRunning($target),     'IsRunning');
	ok(!IsRunning(';;;;'),     'IsRunning');
	ok(SetFront($target),      'SetFront');

}

for my $path (@paths) { SKIP: {
	skip "Mac::Apps::Launch", 4 unless -e $path;

	my $wasrunning = 0;
	for my $psn (keys %Process) {
		$wasrunning = 1, last if $Process{$psn}->processAppSpec =~ /\Q$path/;
	}

	ok(LaunchSpecs($path, 1),  'LaunchSpecs');
	sleep 3;
	for my $psn (keys %Process) {
		if ($Process{$psn}->processAppSpec =~ /\Q$path/) {
			ok(1, "Find $path");
			SKIP: {
				skip "$path was previously running", 1 if $wasrunning;
				ok(kill(SIGTERM, GetProcessPID($psn)), "Kill $path");
				sleep 3;
			}
			last;
		}
	}

	SKIP: {
		skip "$path was previously running", 1 if $wasrunning;
		my $isrunning = 0;
		for my $psn (keys %Process) {
			$isrunning = 1, last if $Process{$psn}->processAppSpec =~ /\Q$path/;
		}
		ok(!$isrunning, "Don't find $path");
	}
} }

SKIP: {
	skip "Mac::Apps::Launch Quit/Launch Finder", 2 unless $ENV{QUITFINDER};

	ok(QuitApps($target),      'QuitApps');
	sleep 5;
	ok(LaunchApps($target),    'LaunchApps');
}

__END__