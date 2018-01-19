# Toasty-Commands
This is where the port of the chat commands from my E2 ToastyHUD will be held, in addition to quite a few new features.

This is a Module for ULX (which can be found [here](https://github.com/TeamUlysses/ulx)). Thus, this addon requires that you have ULX installed. rm requires that you have Falco's Prop Protection installed, which can be found [here](https://github.com/FPtje/Falcos-Prop-protection). alle2s requires, of course, Wiremod to be install ([here](https://github.com/wiremod/wire)).

This addon now includes an anti-cheat. It will watch for client-side changes to the cvars sv\_allowcslua, sv\_cheats, and mat\_wireframe, and auto-bans for a week if it sees fit. Avoids banning admins, instead it notifies the server of the detection.

A number of functions are added to ULX, most extend or use functions defined in ULX. These functions are as follows:

- jban
	- Loads an interface with which one can ban other players with.
	- Records joins and deletes records that are older than 24 hours.
	- Records are saved to a file.
- rm &lt;player(s)&gt; &#91;time in seconds, default is 0&#93;
	- Deletes all the entities of player(s), and jails them for a set amount of time.
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
- fu &lt;player(s);
	- Inverts the viewport of the player(s)
	- Garry's Mod will reset the viewport when the player(s)spawns.
	- Provides an opposite (ulx unfu, say !unfu)
- alle2s
	- Prints all of the Expression 2 chips spawned in the server.
	- Includes the user, Expression name, OP usage, and CPU usage (in us)
- delete &lt;player&gt;
	- Deletes the player (clientside)
- sort &lt;player&gt;
	- Sorts the text sent from the player to chat
	- Opposite is "ulx unsort", say "!unsort"
- pmute &lt;player(s)&gt;
	- Uses pdata to mute the target from commiting text to the chat.
	- Provides an opposite (ulx unpmute, say !unpmute)
- pgag &lt;player(s)&gt;
	- Uses pdata to gag the target from talking into the server.
	- Provides an opposite (ulx unpgag, say !unpgag)
	- This and pmute are like those found in [Custom ULX Commands](https://github.com/cobalt77/Custom-ULX-Commands), and in fact a some of the code in pgag is similar in style to Cobalt77's. These are mostly here to act as replacements for a subset of Custom ULX Commands, as it is aging and gathering more vulnerabilities. A replacement for dban, or at least listjoindscs (or both) is planned.

This addon also extends the jail system. If a player is in jail and disconnects, it notifies all the users on the server. This addon is also capable of auto-banning for leave during jail. If the player reconnects within 24 hours of leaving during the jail, they are banned for the remainder of the 24 hours. Now avoids banning admins. By default, this feature is turned off, but there is a command to enable it:

- enablejailban
	- Writes a file to the DATA folder of the server.
	- Use "ulx enablejailban" in console
	- Opposite is "ulx disablejailban"

