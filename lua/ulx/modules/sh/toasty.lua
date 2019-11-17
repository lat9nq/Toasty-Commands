local CATEGORY_NAME = "Toasty"

local function getTag(ply)
	if (!(ply:IsValid() and not ply:IsBot())) then
		return "0"
	end
	local id = ply:SteamID()
	local idt = string.Explode(":", id)
	return idt[2] .. idt[3]
end

local toast_jail

function ulx.silent_jail(caller, targets, seconds, undo)
	for i=1, #targets do
		local ply = targets[ i ]
		local pos = ply:GetPos()

	end
end

toast_jail = {
	{ pos = Vector(0,0,0), mdl = "models/props_phx/construct/windows/window_angle360.mdl" },
	{ pos = Vector(0,0,0), mdl = "models/props_phx/construct/windows/window_curve360x2.mdl" },
	{ pos = Vector(0,0,95), mdl = "models/props_phx/construct/windows/window_dome360.mdl" }
}
-- This is mostly a clone of ulx's doJail
-- I needed access to my own version
-- And a refresher on gmod lua
toast_doJail = function(target, seconds)
	if (target.jail) then
		return
	end

	if (target:inVehicle()) then
		local vehicle = target:getParent()
		target:ExitVehicle()
		vehicle:Remove()
	end

	if (target.physgunned_by) then
		for ply, target in pairs( target.physgunned_by) do
			
		end
	end
end

function ulx.silent_goto(caller, target)
	if (!caller:IsValid()) then
		print("You cannot goto this target as your are not a in-game player.")
		return
	end

	local pos = target:GetPos()
	local delta = Vector(-200,0,150)
	delta:Rotate(Angle(0,target:EyeAngles().yaw,0))
	pos:Add(delta)
	caller:SetPos(pos)
	caller:SetEyeAngles(Angle(40,target:EyeAngles().yaw,0))
	caller:SetMoveType(MOVETYPE_NOCLIP)
	--caller:ChatPrint("You silently teleported to " .. target:GetName())
	--print(caller:GetName() .. " silently teleported to " .. target:GetName())
	ulx.fancyLogAdmin(caller, true, "#A silently teleported to #T" , target)
end
local sgoto = ulx.command(CATEGORY_NAME, "ulx sgoto", ulx.silent_goto, "!sgoto", true)
sgoto:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
sgoto:defaultAccess(ULib.ACCESS_OPERATOR)
sgoto:help("Goto target without chat relay.")

function ulx.silent_strip(caller, target)
	target:StripWeapons()
	ulx.fancyLogAdmin(caller, true, "#A silently stripped the weapons of #T" , target)
end
local sstrip = ulx.command(CATEGORY_NAME, "ulx sstrip", ulx.silent_strip, "!sstrip", true)
sstrip:addParam{ type=ULib.cmds.PlayerArg }
sstrip:defaultAccess(ULib.ACCESS_ADMIN)
sstrip:help("Silently strip the weapons of a target.")

function ulx.temp_gag(caller, target, time)

	target.ulx_gagged = true
	target:SetNWBool("ulx_gagged", false)

	timer.Create("temp_gag_"..target:GetName()..tostring(math.floor(SysTime())), time, 1, function()
		if (target:IsValid() and target.ulx_gagged) then
			target.ulx_gagged = false
			target:SetNWBool("ulx_gagged", false)
			ulx.fancyLogAdmin(caller, "Ungagged #T", target)
		end
	end )

	ulx.fancyLogAdmin(caller, "#A gagged #T for #i seconds", target, time)
end
local tgag = ulx.command(CATEGORY_NAME, "ulx tgag", ulx.temp_gag, "!tgag")
tgag:addParam{ type=ULib.cmds.PlayerArg }
tgag:addParam{ type=ULib.cmds.NumArg, min = 1, default = 60, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
tgag:defaultAccess(ULib.ACCESS_OPERATOR)
tgag:help("Temporarily gags the target")

local MUTE = 2

function ulx.temp_mute(caller, target, time)

	target.gimp = MUTE
	target:SetNWBool("ulx_muted", false)

	timer.Create("temp_mute_"..target:GetName()..tostring(math.floor(SysTime())), time, 1, function()
		if (target:IsValid() and target.gimp != 0) then
			target.gimp = 0
			target:SetNWBool("ulx_muted", false)
			ulx.fancyLogAdmin(caller, "Unmuted #T", target)
		end
	end )

	ulx.fancyLogAdmin(caller, "#A muted #T for #i seconds", target, time)
end
local tmute = ulx.command(CATEGORY_NAME, "ulx tmute", ulx.temp_mute, "!tmute")
tmute:addParam{ type=ULib.cmds.PlayerArg }
tmute:addParam{ type=ULib.cmds.NumArg, min = 1, default = 60, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
tmute:defaultAccess(ULib.ACCESS_OPERATOR)
tmute:help("Temporarily mutes the target")

function ulx.playwith(caller, target, time, should_stop)
	local targets = { target }

	if (!should_stop) then
		ulx.jail(caller, targets, 0, true)
		--ulx.bring(caller, targets)
	end
	if target:Health() <= 0 then
		ULib.spawn(target)
	end
	ulx.ragdoll(caller, targets, should_stop)
	ulx.gag(caller, targets, should_stop)
	ulx.mute(caller, targets, should_stop)

	if (time > 0 and not should_stop) then
		timer.Create("playwith_"..target:GetName().."_"..tostring(math.floor(SysTime())), time, 1, function ()
			ulx.playwith(caller, target, 0, true)
		end )
	end
end
local playwith = ulx.command(CATEGORY_NAME, "ulx playwith", ulx.playwith, "!playwith")
playwith:addParam{ type=ULib.cmds.PlayerArg }
playwith:addParam{ type=ULib.cmds.NumArg, min = 0, default = 0, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
playwith:addParam{ type=ULib.cmds.BoolArg, invisible=true }
playwith:defaultAccess(ULib.ACCESS_ADMIN)
playwith:help("Does quite a few things to a target...")
playwith:setOpposite("ulx unplaywith", {_, _, _, true}, "!unplaywith")


function ulx.rm(caller, targets, time)
	--local targets = { target }
	local entities = ents.GetAll()

	for _,target in pairs(targets) do
		for _,e in pairs(entities) do
			if (e.FPPOwnerID and e.FPPOwnerID == target:SteamID()) then
				e:Remove()
			end
		end
	end

	ulx.jail(caller, targets, time, false)
	ulx.fancyLogAdmin(caller, "#A removed all entities from #T", targets)
end
local rm = ulx.command(CATEGORY_NAME, "ulx rm", ulx.rm, "!rm")
rm:addParam{ type=ULib.cmds.PlayersArg }
rm:addParam{ type=ULib.cmds.NumArg, min = 0, default = 0, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
rm:defaultAccess(ULib.ACCESS_OPERATOR)
rm:help("Clears the entities of and jails the target(s).")

hook.Add("PlayerDisconnected", "Toast_Ban_On_Disconnect", function(ply)
	local tag = tonumber(getTag(ply))

	if (ply:IsListenServerHost() or ply:IsBot()) then return end
	if not ply.due_for_ban then return end

	local caller = ply
	local id = ply:SteamID()
	local time = ply.due_for_ban.time
	local reason = ply.due_for_ban.reason

	local tstring = "for #s"
	if (time == 0) then
		tstring = "permanently"
	end

	local rsn = ""
	if (reason and reason ~= "") then
		rsn = " (#s)"
	end

	--Some of this code was pulled from ULX
	ulx.fancyLogAdmin(caller, "#A <#s> was banned " .. tstring .. rsn .. " on disconnect.",
			id,
			time ~= 0 and ULib.secondsToStringTime( time * 60 ) or reason,
			reason
	)

	ULib.queueFunctionCall(ULib.addBan, id, time, reason, id, caller)
end)

function ulx.disconnect_ban(caller, target, t, r, undo)
	if not undo then
		if not (target:IsValid() and !target:IsBot()) then
			return
		end

		target.due_for_ban = {
			time = t,
			reason = r
		}

		local tstring = "for #s"
		if (t == 0) then
			tstring = "permanently"
		end
		local rsn = ""

		if (r and r ~= "") then
			rsn = " (#s)"
		end

		ulx.fancyLogAdmin(caller, "#A will ban #T " .. tstring .. rsn .. " on disconnect", target, t~=0 and ULib.secondsToStringTime(t*60) or r, r)
	else
		if not target.due_for_ban then
			ULib.tsayError(caller, "This player is not due for banning", true)
			return
		end

		target.due_for_ban = nil

		ulx.fancyLogAdmin(caller, "#A revoked the ban on #T", target)
	end
end
local dscban = ulx.command(CATEGORY_NAME, "ulx dscban", ulx.disconnect_ban, "!dscban")
dscban:addParam{ type=ULib.cmds.PlayerArg }
dscban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.allowTimeString, min=0 }
dscban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
dscban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
dscban:defaultAccess(ULib.ACCESS_ADMIN)
dscban:help("Bans the target when they disconnect.")
dscban:setOpposite("ulx undscban", { _, _, _, _, true }, "!undscban")

function ulx.fuckup(caller, targets, undo)
	local roll = 180
	if undo then roll = 0 end

	for _,target in pairs(targets) do
		target:SetEyeAngles(Angle(
					target:EyeAngles().pitch,
					target:EyeAngles().yaw,
					roll
			)
		)
	end

	local str = "fucked up"
	if undo then str = "righted the angles of" end

	ulx.fancyLogAdmin(caller, true, "#A " .. str .. " #T", targets)
end
local fu = ulx.command(CATEGORY_NAME, "ulx fu", ulx.fuckup, "!fu", true)
fu:addParam{ type=ULib.cmds.PlayersArg }
fu:addParam{ type=ULib.cmds.BoolArg, invisible=true }
fu:defaultAccess(ULib.ACCESS_ADMIN)
fu:help("Inverts the viewport for the target. Resets when they die.")
fu:setOpposite("ulx unfu", { _, _, true }, "!unfu")

function ulx.alle2s(caller)
	local es = ents.GetAll()

	for _, e in pairs(es) do
		if (e:GetClass() == "gmod_wire_expression2") then
			if (e:IsValid() and e.GetGateName) then
				if (e.FPPOwnerID) then
					caller:PrintMessage(HUD_PRINTTALK, player.GetBySteamID(e.FPPOwnerID):GetName() ..
						"'s " .. e:GetGateName() .. ": using " ..
						tostring(math.floor(e.context.prfbench)) .. " ops, " .. tostring(math.floor(1000000 * e.context.timebench)) .. " us")
				end
			end
		end
	end
end
local alle2s = ulx.command(CATEGORY_NAME, "ulx alle2s", ulx.alle2s, "!alle2s", true)
alle2s:defaultAccess(ULib.ACCESS_OPERATOR)
alle2s:help("Prints out all the Expression 2 chips spawned in the server.")

function ulx.delete(caller, target)
	ulx.fancyLogAdmin(caller, "#A deleted #T", target)

	-- the following code is taken from https://gmod.facepunch.com/f/gmoddev/mjea/How-to-crash-a-player-s-game-or-his-computer/1/
	target:SendLua("LocalPlayer = nil")
	target:SendLua("cam.Start3D2D( Vector(0, 0, 0), Angle(0, 0, 0), 1 )")
end
--local del = ulx.command(CATEGORY_NAME, "ulx delete", ulx.delete, "!delete")
--del:addParam{ type=ULib.cmds.PlayerArg }
--del:defaultAccess(ULib.ACCESS_SUPERADMIN)
--del:help("Deletes the player from the server.")


function ulx.enablejailban(caller, unset)
	toast_auto_ban = not unset
	local str = "#A "

	local f = file.Open(toastab_filename, "w", "DATA")

	if (unset) then
		f:Write("0")
		str = str .. "disabled"
	else
		f:Write("1")
		str = str .. "enabled"
	end
	str = str .. " auto-ban for disconnect from jail."

	f:Close()
	f = nil

	ulx.fancyLogAdmin(caller, str)
end
local ejb = ulx.command(CATEGORY_NAME, "ulx enablejailban", ulx.enablejailban, nil)
ejb:addParam{ type=ULib.cmds.BoolArg, invisible = true }
ejb:defaultAccess(ULib.ACCESS_SUPERADMIN)
ejb:help("Enables/Disables auto-banning for leaving during jail.")
ejb:setOpposite("ulx disablejailban", {_, true}, nil)

hook.Add("PlayerSay", "toastSort", function(ply, strText, bTeam)
	if (ply.sort and not ply:GetNWBool("ulx_gimped") and not ply:GetNWBool("ulx_muted")) then
		local result = ""
		local c = string.char(-1)
		for i = 31, 126 do
			c = string.char(i)
			for j = 0, string.len(strText) do
				local x = string.sub(strText, j, j)
				if (c == x) then
					result = result .. x
				end
			end
		end
		return result
	end
end)

function ulx.sort(caller, target, unset)
	local changed = false

	if not target.sort and not unset then
		changed = true
		target.sort = true
	elseif unset then
		changed = true
		target.sort = nil
	end

	if changed then
		local str = "#A"
		if unset then
			str = str .. " unsorted "
		else
			str = str .. " sorted "
		end
		str = str .. "#T"
		ulx.fancyLogAdmin(caller, str, target)
	end
end
local sort = ulx.command(CATEGORY_NAME, "ulx sort", ulx.sort, "!sort")
sort:addParam{ type=ULib.cmds.PlayerArg }
sort:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sort:defaultAccess(ULib.ACCESS_OPERATOR)
sort:help("Sorts the player's text in chat.")
sort:setOpposite("ulx unsort", {_, _, true}, "!unsort")

function ulx.pmute(caller, targets, unpmute)
	local val = !unpmute
	if unpmute == true then val = nil end
	for _, p in pairs(targets) do
		if (p:IsValid()) then
			p:SetPData("permmuted", val)
			p.perma_muted = val
		end
	end

	local str = "#A "
	if (unpmute) then
		str = str .. "un-"
	end
	str = str .. "permanently muted #T"

	ulx.fancyLogAdmin(caller, str, targets)
end
local pmute = ulx.command(CATEGORY_NAME, "ulx pmute", ulx.pmute, "!pmute")
pmute:addParam{ type=ULib.cmds.PlayersArg }
pmute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pmute:defaultAccess(ULib.ACCESS_ADMIN)
pmute:help("Mutes the targets using pdata")
pmute:setOpposite("ulx unpmute", {_, _, true}, "!unpmute")

hook.Add("PlayerInitialSpawn", "TAM_IsPMuted", function(ply)
	if (ply:GetPData("permmuted") == true) then
		for _, p in pairs(player.GetAll()) do
			if p:IsAdmin() then
				ULib.tsayError(p, ply:GetName() .. " has joined the server and is permanently muted!")
			end
		end
	end
	ply.perm_muted = true
end)

hook.Add("PlayerDisconnected", "TAM_IsPMuted_Disconnect", function(ply)
	if (ply.perma_muted) then
		for _, p in pairs(player.GetAll()) do
			if p:IsAdmin() then
				ULib.tsayError(p, ply:GetName() .. " has left the server and is permanently muted!")
			end
		end
	end
end)

hook.Add("PlayerSay", "TAM_PMuteSay", function(ply)
	if (ply.perma_muted) then
		return ""
	end
end)

function ulx.pgag(caller, targets, unpgag)
	local val = !unpgag
	if unpgag == true then val = nil end
	for _, p in pairs(targets) do
		if (p:IsValid()) then
			p:SetPData("permgagged", val)
			p.perma_gagged = val
		end
	end

	local str = "#A "
	if (unpgag) then
		str = str .. "un-"
	end
	str = str .. "permanently gagged #T"

	ulx.fancyLogAdmin(caller, str, targets)
end
local pgag = ulx.command(CATEGORY_NAME, "ulx pgag", ulx.pgag, "!pgag")
pgag:addParam{ type=ULib.cmds.PlayersArg }
pgag:addParam{ type=ULib.cmds.BoolArg, invisible=true }
pgag:defaultAccess(ULib.ACCESS_ADMIN)
pgag:help("Gags the targets using pdata")
pgag:setOpposite("ulx unpgag", {_, _, true}, "!unpgag")

hook.Add("PlayerInitialSpawn", "TAM_IsPGagged", function(ply)
	if (ply:GetPData("permgagged") == true) then
		for _, p in pairs(player.GetAll()) do
			if p:IsAdmin() then
				ULib.tsayError(p, ply:GetName() .. " has joined the server and is permanently gagged!")
			end
		end
	end
	ply.perm_gagged = true
end)

hook.Add("PlayerDisconnected", "TAM_IsPGagged_Disconnect", function(ply)
	if (ply.perma_gagged) then
		for _, p in pairs(player.GetAll()) do
			if p:IsAdmin() then
				ULib.tsayError(p, ply:GetName() .. " has left the server and is permanently gagged!")
			end
		end
	end
end)

local shakespeare_quotes = {
	"Cowards die many times before their deaths; The valiant never taste of death but once.",
	"I love you with so much of my heart that none is left to protest.",
	"Thou art a very ragged Wart.",
	"Is this a dagger which I see before me...",
	"That it should come to this!",
	"Do you think I am easier to be played on than a pipe?",
	"Alas, poor Yorick! I knew him, Horatio...",
	"Away! Thou'rt poison to my blood.",
	"O thou vile one!",
	"Take you me for a sponge?",
	"More of your conversation would infect my brain.",
	"A horse! a horse! my kingdom for a horse!",
	"Off with his head!",
	"Et tu, Brute!",
	"Such antics do not amount to a man.",
	"They were devils incarnate.",
	"Hag of all despite!",
	"Out, dunghill!",
	"You are strangely troublesome.",
	"You blocks, you stones, you worse than senseless things!",
	"Thou mis-shapen dick!",
	"I do desire we may be better strangers."
}

function ulx.shakesban(caller, target, time)

	local tstring = "for #s"
	local id = target:SteamID()
	local reason = shakespeare_quotes[math.floor(math.rand(1, #shakespeare_quotes))]

	if (time == 0) then
		tstring = "permanently"
	end

	ulx.fancyLogAdmin(caller, "#A banned #T " .. tstring .. " (#s)",
			target,
			time ~= 0 and ULib.secondsToStringTime(time * 60) or reason,
			reason)
	
	--print(reason)

	ULib.queueFunctionCall(ULib.addBan, id, time, reason, id, caller)
end
local shakesban = ulx.command(CATEGORY_NAME, "ulx shakesban", ulx.shakesban, "!shakesban")
shakesban:addParam{ type=ULib.cmds.PlayerArg }
shakesban:addParam{ type=ULib.cmds.NumArg, min = 0, default = 0, hint = "minutes, 0 for perma", ULib.cmds.optional, ULib.allowTimeStirng }
shakesban:defaultAccess(ULib.ACCESS_ADMIN)
shakesban:help("Bans the target with a quote from Shakespeare.")

-- the following was referenced from Custom ULX Commands by Cobalt77

hook.Add("PlayerCanHearPlayersVoice", "TAM_PGagTalk", function(listener, talker)
	if (talker.perma_gagged) then
		return false
	end
end)
-- end reference
