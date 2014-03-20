[1]: https://github.com/mikejsavage/rssc
[2]: http://keplerproject.github.io/luafilesystem/
[3]: http://lua.sqlite.org/
[4]: http://msmtp.sourceforge.net/

rssc-sendmail reads databases created by [rssc][1], emails you any
unread articles and marks everything read.

Dependencies
------------

lua 5.1, [luafilesystem][2], [lsqlite3][3], [rssc][1]

Usage
-----

Building:

	$ git clone https://github.com/mikejsavage/rssc-sendmail
	$ make
	$ make install

To run (in this case every 15 minutes and as the `rssc` user), add an
entry like the following to your crontab:

	*/15 * * * * rssc rssc && rssc-sendmail

Configuration
-------------

rssc-sendmail reads `/etc/rssc_sendmail.conf` and looks for the
following settings:

- **from** - from address
- **to** - to address
- **sendmail** (optional) - a command to run instead of sendmail

An example minimal config:

	from = "rssc@myself.com"
	to = "me@myself.com"

[msmtp][4] + gmail example:

	from = "me@gmail.com"
	to = "me+rssc@gmail.com"
	sendmail = "msmtp -a gmail"
