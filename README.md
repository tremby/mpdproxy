mpdproxy
========

Provide passwordless access to an MPD server for clients within whitelisted 
ranges.

Setting up MPD
--------------

Set up MPD to run on a non-standard port. I use 6601 rather than the default 
6600.

Installation
------------

Clone this repository

Configuration
-------------

Copy `config.coffee.example` to `config.coffee` and edit it to give the real 
MPD's host, port and password, the port the proxy server should run on and the 
IP address ranges which should have passwordless access.

Testing
-------

1. Start a foreground session with `coffee mpdproxy.coffee` to test.
2. Connect to MPD on the proxy's host and port from whitelisted and 
   non-whitelisted IPs. You shouldn't be asked for a password from whitelisted 
   IPs but should be from non-whitelisted IPs. Some basic information is logged 
   to the console.
3. Quit (control-c).

Running a daemon
----------------

Running `npm start` starts the proxy daemonized. It logs to `daemon.out.log` and 
`daemon.err.log`.

Running at startup
------------------

One way to do this is to put a line like this in your `/etc/rc.local`:

	su - youruser -c 'cd /path/to/mpdproxy && npm start'

Running directly
----------------

`mpdproxy.coffee` has a [hashbang](https://en.wikipedia.org/wiki/Shebang_(Unix)) which allows shells to know the script is to be executed with `coffee`. This allows a symlink to be made to `mpdproxy.coffee` from any directory in your `PATH`, such as your `$HOME/bin` or `/usr/local/bin` directory.

Author
------

Bart Nagel <bart@tremby.net>

Licence
-------

MIT
