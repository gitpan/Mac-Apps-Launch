#-----------------------------------------------------------------#
#  Launch.pm
#  pudge
#  Launch App by ID
#
#  Created:       Chris Nandor (pudge@pobox.com)         08-Oct-97
#  Last Modified: Chris Nandor (pudge@pobox.com)         13-Oct-97
#-----------------------------------------------------------------#
#  All this does is launch Mac programs by their application ID
#  In the examples below, BBEdit, Anarchie and MacPGP are launched
#
#  use Mac::Apps::Launch;
#  my @apps = qw(R*ch Arch MPGP);
#  LaunchApps([@apps],1);           # launch and switch to front
#  LaunchApps([@apps],0);           # launch and don't switch 
#-----------------------------------------------------------------#
package Mac::Apps::Launch;
require 5;
use Exporter;
use Carp;
use Carp;
use strict;
use vars qw($revision $VERSION %Application @ISA @EXPORT);
#-----------------------------------------------------------------
$revision = '$Id: Mac::Apps::Launch,v 1.0 1997/10/13 16:48 EDT cnandor Exp $';
$VERSION  = '1.0';
@ISA 		= qw(Exporter);
@EXPORT 	= qw(LaunchApps);
#-----------------------------------------------------------------
use Mac::Processes;
use Mac::MoreFiles(%Application);
sub LaunchApps {
	my $apps = $_[0];
	my $switch;
	if ($_[1] == 1) {
		$switch = eval(launchContinue+launchNoFileFlags)
	} else {
		$switch = eval(launchContinue+launchNoFileFlags+launchDontSwitch)
	}
	foreach (@$apps) {
		if ($] >= 5.004) {
			my $Launch = new LaunchParam(
				launchControlFlags => $switch,
				launchAppSpec      => $Application{$_}
			);
			LaunchApplication($Launch) || croak $^E;
		} else {
			my(%Launch);
			no strict 'subs';
			tie %Launch, LaunchParam;
			$Launch{launchControlFlags} = $switch;
			$Launch{launchAppSpec}		= $Application{$_};
			LaunchApplication(\%Launch) or croak $^E;
			use strict 'subs';
		}
	}
}
#-----------------------------------------------------------------
