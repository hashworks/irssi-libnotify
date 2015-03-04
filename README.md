# irssi-libnotify

This is a fork of [stickster's irssi-libnotify](http://code.google.com/p/irssi-libnotify/).<br/>
Currently the only difference is a new configuration variable to set the path of `irssi-notifier.sh`.

irssi-libnotify is a slightly nicer D-Bus approach that plays nicely with the GNOME Shell's notification area.  If you are looking for the older, simpler version using libnotify, simply check out the old-libnotify branch instead.

To make this script work better for people who use irssi remotely via SSH (often with screen), I've separated out the actual notifier into a small listener program.  That piece is written in Python so it should be easy to read and understand.


### REQUIREMENTS

 * irssi
 * libnotify >= 0.7  (but slightly older libnotify may work)
 * pygobject >= 3.0
 * perl-HTML-Parser


### INSTRUCTIONS

1. Clone this repository.
2. Excecute `notify-listener.py` when your desktop environment is loaded.
3. Link `notify.pl` to `$HOME/.irssi/scripts/` (or `$HOME/.irssi/scripts/autorun/`).
4. Set the path of `irssi-notifier.sh` by `/SET notify_sh_path <path>`
4. Load the script by `/load notify.pl` or `/load autorun/notify.pl`

If you are running irssi remotely, currently your remote machine account would need to be able to SSH back to your local box without a passphrase.  You'll need to set that up yourself, using 'ssh-copy-id' or another method.
<br/><br/>
Then in irssi, use `/SET notify_remote <HOST>` to activate the remote notification bit.  Replace <HOST> with the name or IP address of the local machine you're on, *as it would be known to the remote machine*.  This is most useful if you're on the same local network with the other box; firewalls or other non-local routing will probably make it difficult to use this feature.
<br/><br/>
In the future I'm going to add a feature to provide messages raw over a remotely forwarded port, so you won't need any special key handling or have to worry about firewalls and other such stuff. Thanks for trying this out.
