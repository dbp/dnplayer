About
-----

This is a really simple video player for the news program [Democracy
Now!](http://democracynow.org). It always plays the most recent
day's show, and will remember where you are. It can synchronize this
across devices; you just have to visit the url of the player you
create at least once on each device. A demo of this is running at
[lab.dbpmail.net/dn](http://lab.dbpmail.net/dn/).

Install
-------

The backend is written with
[Ur/Web](http://www.impredicative.com/ur/), with one minor patch to
add support for different tags[1]; if you install it, and sqlite, you
should be able to build it using the Makefile. Populate the sqlite
database with `sqlite3 dn.db < dn.sql` and you should be able to start
it with `./dn.exe`. The only target in the Makefile you will need to
change is deploy, for obvious reasons. And if you don't want to depend
upon my server being up, or want to change the javascript, you might
want to host the .js file on your own, and change the script
declarations in the .urp files.

1. We need `<code>` and `<meta>` tags. If you edit `lib/ur/basis.urs`, add these lines:

    val meta : unit -> tag [Nam = string, Content = string] head [] [] []


    val code : bodyTag boxAttrs

Compatibility
-------------

Right now, the most stable target is Chrome (on computers). It works on
iPhones/iPads and Chrome on Android, but there may be a timing bug on
slow connections. Firefox doesn't work because it doesn't support
the (proprietary) formats that DN! provides, and I haven't wired up
a Flash fallback (yes, I've tried JW Player, MediaElement, and Video.js.
All were buggy / didn't support in a browser agnostic way what I needed -
it seems that until HTML5 video/audio stabilizes, the only way is to
target browsers by hand).

Bugs
----

Sort of a decision rather than a true bug, but to simplify the problem
of certain browsers (I'm looking at you, mobile) having strange
policies about seeking (both when they allow it, and when the seeked
time is reflected in the currentTime), the backend only increases the
offset it records (unless you are starting on a new day, of course).
This means that if you seek backwards manually in the show, this will
not be reflected if you reload or open it in another browser. Since
this is most likely a real edge case (most people watch sequentially,
and if they do seek back, it is to listen to what was just played, and
won't likely switch devices / reload before they reach their old
position), and the issue of a mobile browser resetting the offset to 0
because the currentTime hasn't been updated (though it should have
been) is a big problem and something that would be noticed every time
it happened, I think this is justified. But, really, it is a bug.


Future/Todo
-----------

* Figure out a fallback for browsers that don't support MP4/MP3 (ie, firefox).