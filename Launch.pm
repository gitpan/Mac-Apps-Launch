package Mac::Apps::Launch;
require 5.004;
use Exporter;
use Carp;
use strict;
no strict 'refs';
use vars qw($revision $VERSION %Application @ISA @EXPORT);
use Mac::Processes;
use Mac::MoreFiles(%Application);
use Mac::AppleEvents;
#-----------------------------------------------------------------
$VERSION = '1.50';
@ISA     = qw(Exporter);
@EXPORT  = qw(LaunchApps QuitApps QuitAllApps IsRunning);
#-----------------------------------------------------------------
sub QuitAllApps {
    my $warn = 1;
    my $keepapps = 'MACS|McPL|hhgg';
    foreach (@_) {$keepapps .= "|$_"}
    my @apps = ();
    foreach my $psn (keys %Process) {
        my $proc = $Process{$psn};
        my $sig = $proc->processSignature();
        next if ($sig =~ /$keepapps/); # apps to keep running
        push @apps, $sig;
    }

    foreach (@apps) {
        my $e = AEBuildAppleEvent(
            'aevt','quit',typeApplSignature,$_,0,0,''
        ) || ($warn = 0);
        my $r = AESend($e, kAEWaitReply) || ($warn = 0);
        AEDisposeDesc($e) if $e;
        AEDisposeDesc($r) if $r;
    }
    return $warn;
}
#-----------------------------------------------------------------
sub QuitApps {
    my $warn = 1;
    my @apps = @_;
    foreach (@apps) {
        my $e = AEBuildAppleEvent(
            'aevt','quit',typeApplSignature,$_,0,0,''
        ) || ($warn = 0);
        my $r = AESend($e, kAEWaitReply) || ($warn = 0);
        AEDisposeDesc($e) if $e;
        AEDisposeDesc($r) if $r;
    }
    return $warn;
}
#-----------------------------------------------------------------
sub LaunchApps {
    my $warn = 1;
    my $apps = $_[0];
    my($switch, %open);

    if ($_[1] && $_[1] == 1) {
        $switch = eval(launchContinue+launchNoFileFlags)
    } else {
        $switch = eval(launchContinue+launchNoFileFlags+launchDontSwitch)
    }

    while(my($n, $i) = each(%Process)) {
        $open{$i->processSignature()} = $i->processAppSpec();
    }

    foreach (@$apps) {
        if ($Application{$_}) {
            my $app_spec = exists($open{$_}) ? $open{$_} : $Application{$_};
            my $Launch = new LaunchParam(
                launchControlFlags => $switch,
                launchAppSpec      => $app_spec
            );
            LaunchApplication($Launch) || ($warn = 0);
        } else {
            $warn = 0;
        }
    }
    return $warn;
}
#-----------------------------------------------------------------
sub IsRunning {
    my %x;
    foreach (keys %Process) {
        $x{$Process{$_}->processSignature} = 1
    }
    return exists $x{shift()};
}
#-----------------------------------------------------------------

1;
__END__

=head1 NAME

Mac::Apps::Launch - MacPerl module to launch applications

=head1 SYNOPSIS

    use Mac::Apps::Launch;
    my @apps = qw(R*ch Arch MPGP);
    LaunchApps([@apps], 1) || warn($^E); # launch and switch to front
    LaunchApps([@apps])    || warn($^E); # launch and don't switch 
    QuitApps(@apps)        || warn($^E); # quit @apps
    QuitAllApps(@apps)     || warn($^E); # quit all except @apps
    IsRunning('MACS');                   # returns boolean for whether
                                         # given app ID is running

=head1 DESCRIPTION

Simply launch or quit applications by their creator ID.  The Finder can be quit in this way, though it cannot be launched in this way.

This module is used by several other modules.

This module as written does not work with MacPerls prior to 5.1.4r4.

=head1 EXPORT

Exports functions C<QuitApps()>, C<QuitAllApps()>, and C<LaunchApps()>.

=head1 HISTORY

=over 4

=item v.1.50, September 16, 1998

Added C<IsRunning()>.

=item v.1.40, August 3, 1998

Only launches application if not already open; e.g., won't launch newer version
it finds if older version is open.

=item v.1.31, May 18, 1998

Added AEDisposeDesc() (D'oh!).  Dunno why I forgot this.

=item v.1.3, January 3, 1998

General cleanup, rewrite of method implementation, no longer support versions prior to 5.1.4r4, addition of Quit methods, methods return undef on failure (most recent error in C<$^E>, but could be multiple errors; oh well).

=back

=head1 AUTHOR

Chris Nandor F<E<lt>pudge@pobox.comE<gt>>
http://pudge.net/

Copyright (c) 1998 Chris Nandor.  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.  Please see the Perl Artistic License.

=head1 VERSION

Version 1.50 (16 September 1998)

=cut
