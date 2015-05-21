##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##	   /load perl
##	   /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI $connectTime);
use HTML::Entities;

$VERSION = "0.6";
%IRSSI = (
	authors	 => 'Luke Macken, Paul W. Frields, hashworks',
	contact	 => 'lewk@csh.rit.edu, stickster@gmail.com, admin@hashworks.net',
	name		=> 'notify.pl',
	description => 'Use D-Bus to alert user to hilighted messages',
	license	 => 'GNU General Public License v3',
	url		 => 'https://github.com/hashworks/irssi-libnotify',
);

$connectTime = time;

Irssi::settings_add_str('notify', 'notify_remote', '');
Irssi::settings_add_str('notify', 'notify_sh_path', './irssi-notifier.sh');
Irssi::settings_add_str('notify', 'notify_debug', '');
Irssi::settings_add_str('notify', 'notify_start_offset', '0');

sub sanitize {
	my ($text) = @_;
	encode_entities($text,'\'<>&');
	my $apos = "&#39;";
	my $aposenc = "\&apos;";
	$text =~ s/$apos/$aposenc/g;
	$text =~ s/"/\\"/g;
	$text =~ s/\$/\\\$/g;
	$text =~ s/`/\\"/g;
	return $text;
}

sub notify {

	if (time - $connectTime <= Irssi::settings_get_str('notify_start_offset')) {
		return;
	}

	my ($server, $summary, $message) = @_;

	# Make the message entity-safe
	$summary = sanitize($summary);
	$message = sanitize($message);
	my $sh_path = Irssi::settings_get_str('notify_sh_path');

	my $debug = Irssi::settings_get_str('notify_debug');
	my $nodebugstr = '- ';
	if ($debug ne '') {
	$nodebugstr = '';
	}
	my $cmd = "EXEC " . $nodebugstr .
	$sh_path .
	" dbus-send --session /org/irssi/Irssi org.irssi.Irssi.IrssiNotify" .
	" string:'" . $summary . "'" .
	" string:'" . $message . "'";
	$server->command($cmd);

	my $remote = Irssi::settings_get_str('notify_remote');
	if ($remote ne '') {
	my $cmd = "EXEC " . $nodebugstr . "ssh -q " . $remote . " \"".
		$sh_path .
		" dbus-send --session /org/irssi/Irssi org.irssi.Irssi.IrssiNotify" .
		" string:'" . $summary . "'" .
		" string:'" . $message . "'\"";
	#print $cmd;
	$server->command($cmd);
	}

}

sub print_text_notify {
	my ($dest, $text, $stripped) = @_;
	my $server = $dest->{server};

	return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
	my $sender = $stripped;
	$sender =~ s/^\<.([^\>]+)\>.+/\1/ ;
	$stripped =~ s/^\<.[^\>]+\>.// ;
	my $summary = $dest->{target} . ": " . $sender;
	notify($server, $summary, $stripped);
}

sub server_connected {
	$connectTime = time;	
}

sub message_private_notify {
	my ($server, $msg, $nick, $address) = @_;

	return if (!$server);
	notify($server, "PM from ".$nick, $msg);
}

sub dcc_request_notify {
	my ($dcc, $sendaddr) = @_;
	my $server = $dcc->{server};

	return if (!$dcc);
	notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add ('server connected', 'server_connected');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');
