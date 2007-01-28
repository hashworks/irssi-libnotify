##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use Net::DBus qw(:typing);


$VERSION = "0.01";
%IRSSI = (
    authors     => 'Luke Macken, Paul W. Frields',
    contact     => 'lewk@csh.rit.edu, stickster@gmail.com',
    name        => 'notify.pl',
    description => 'Use libnotify to alert user to hilighted messages',
    license     => 'GNU General Public License',
    url         => 'http://lewk.org/log/code/irssi-notify',
);

Irssi::settings_add_str('notify', 'notify_icon', 'gtk-dialog-info');
Irssi::settings_add_str('notify', 'notify_time', '5000');

sub notify {
    my ($server, $summary, $message) = @_;
    my $bus = Net::DBus->session;
    my $svc = $bus->get_service("org.freedesktop.Notifications");
    my $obj = $svc->get_object("/org/freedesktop/Notifications");

    # Make the message entity-safe.  This is all a crappy hack and I'd
    # love to know a Perl-ish way to do this properly.
    $message =~ s/&/&amp;/g;
    $message =~ s/</&lt;/g;
    $message =~ s/>/&gt;/g;
    $message =~ s/'/&apos;/g;

    $obj->Notify("notification.pl",
		 0,
		 '',
		 $summary,
		 $message,
		 ['Close', 'Close'],
		 {0, 0, 0}, 
		 5_000);
}
 
sub print_text_notify {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};

    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    notify($server, $dest->{target}, $stripped);
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;

    return if (!$server);
    notify($server, "Private message from ".$nick, $msg);
}

sub dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$server || !$dcc);
    notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');
