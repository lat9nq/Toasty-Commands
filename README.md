# Toasty-Commands
This is where the port of the chat commands from my E2 ToastyHUD will be held.

This is a Module for ULX (which can be found [here](https://github.com/TeamUlysses/ulx)). Thus, this addon requires that you have ULX installed.

A number of functions are added to ULX, most extend or use functions defined in ULX. These functions are as follows:

- rm &lt;player&gt; &#91;time in seconds, default is 0&#93;
	- Deletes all the entities of player, and jails them for a set amount of time.
- sgoto &lt;player&gt;
	- Teleports the user to the selected player, without relay in chat.
- sstrip &lt;player&gt;
	- Strips the weapons of the player, without relay in chat.
- tgag &lt;player&gt; &#91;time in seconds, default is 60&#93;
	- Gags the selected player for the specified number of seconds.
- tmute &lt;player&gt; &#91;time in seconds, default is 60&#93;
	- Mutes the selected player for the specified number of seconds.
- playwith &lt;player&gt; &#91;time in seconds, default is 0&#93;
	- Performs a number of ULX commands on the target, specifically:
		- ulx unjail
		- ulx bring
		- ulx ragdoll
		- ulx gag
		- ulx mute
	- It performs those action in that order
	- Provides an opposite (ulx unplaywith, say !unplaywith)
- dscban &lt;player&gt; &#91;time in seconds, default is 0 (perma)&#93; &#91;reason&#93;
	- Sets up a ban. When the player disconnects, it automatically bans them.
	- Provides an opposite (ulx undscban, say !undscban)
- fu &lt;player&gt;
	- Inverts the viewport of the player.
	- Garry's Mod will reset the viewport when the player respawns.
	- Provides an opposite (ulx unfu, say !unfu)
- alle2s
	- Prints all of the Expression 2 chips spawned in the server.
	- Includes the user, Expression name, OP usage, and CPU usage (in us)
- delete
	- Deletes the player (clientside)

This addon also extends the jail system. If a player is in jail and disconnects, it notifies all the users on the server. This addon is also capable of auto-banning for leave during jail. If the player reconnects within 24 hours of leaving during the jail, they are banned for the remainder of the 24 hours. By default, this feature is turned off, but there is a command to enable it:

- enablejailban
	- Writes a file to the DATA folder of the server.
	- Opposite is "ulx disablejailban"
