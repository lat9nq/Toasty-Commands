local CATEGORY_NAME = "Toasty"

toast = {}

local function getTag(ply)
	if (!(ply:IsValid() and not ply:IsBot())) then
		return "0"
	end
	local id = ply:SteamID()
	local idt = string.Explode(":", id)
	return idt[2] .. idt[3]
end

function toast.silent_goto(caller, target)
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
local sgoto = ulx.command(CATEGORY_NAME, "ulx sgoto", toast.silent_goto, "!sgoto", true)
sgoto:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
sgoto:defaultAccess(ULib.ACCESS_OPERATOR)
sgoto:help("Goto target without chat relay.")

function toast.silent_strip(caller, target)
	target:StripWeapons()
	ulx.fancyLogAdmin(caller, true, "#A silently stripped the weapons of #T" , target)
end
local sstrip = ulx.command(CATEGORY_NAME, "ulx sstrip", toast.silent_strip, "!sstrip", true)
sstrip:addParam{ type=ULib.cmds.PlayerArg }
sstrip:defaultAccess(ULib.ACCESS_ADMIN)
sstrip:help("Silently strip the weapons of a target.")

function toast.temp_gag(caller, target, time)

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
local tgag = ulx.command(CATEGORY_NAME, "ulx tgag", toast.temp_gag, "!tgag")
tgag:addParam{ type=ULib.cmds.PlayerArg }
tgag:addParam{ type=ULib.cmds.NumArg, min = 1, default = 60, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
tgag:defaultAccess(ULib.ACCESS_OPERATOR)
tgag:help("Temporarily gags the target")

local MUTE = 2

function toast.temp_mute(caller, target, time)

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
local tmute = ulx.command(CATEGORY_NAME, "ulx tmute", toast.temp_mute, "!tmute")
tmute:addParam{ type=ULib.cmds.PlayerArg }
tmute:addParam{ type=ULib.cmds.NumArg, min = 1, default = 60, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
tmute:defaultAccess(ULib.ACCESS_OPERATOR)
tmute:help("Temporarily mutes the target")

function toast.playwith(caller, target, time, should_stop)
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
			toast.playwith(caller, target, 0, true)
		end )
	end
end
local playwith = ulx.command(CATEGORY_NAME, "ulx playwith", toast.playwith, "!playwith")
playwith:addParam{ type=ULib.cmds.PlayerArg }
playwith:addParam{ type=ULib.cmds.NumArg, min = 0, default = 0, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
playwith:addParam{ type=ULib.cmds.BoolArg, invisible=true }
playwith:defaultAccess(ULib.ACCESS_ADMIN)
playwith:help("Does quite a few things to a target...")
playwith:setOpposite("ulx unplaywith", {_, _, _, true}, "!unplaywith")

function toast.rm(caller, targets, time)
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
local rm = ulx.command(CATEGORY_NAME, "ulx rm", toast.rm, "!rm")
rm:addParam{ type=ULib.cmds.PlayersArg }
rm:addParam{ type=ULib.cmds.NumArg, min = 0, default = 0, hint = "seconds", ULib.cmds.round, ULib.cmds.optional }
rm:defaultAccess(ULib.ACCESS_ADMIN)
rm:help("Clears the entities of and jails the target(s).")

local to_ban_reasons = {}
local to_ban_ids = {}
local to_ban_times = {}
local to_ban_revoked = {}
local to_ban_callers = {}

hook.Add("PlayerDisconnected", "Toast_Ban_On_Disconnect", function(ply)
	local tag = tonumber(getTag(ply))

	if (ply:IsListenServerHost() or ply:IsBot()) then return end
	if (to_ban_revoked[tag] == nil or to_ban_revoked[tag] == true) then return end

	local caller = to_ban_callers[tag]
	local id = to_ban_ids[tag]
	local time = to_ban_times[tag]
	local reason = to_ban_reasons[tag]

	local tstring = "for #s"
	if (time == 0) then
		tstring = "permanently"
	end

	local rsn = ""
	if (reason and reason ~= "") then
		rsn = " (#s)"
	end

	--Some of this code was pulled from ULX
	ulx.fancyLogAdmin(caller, "#A banned <#s> " .. tstring .. rsn .. " on disconnect.",
			id,
			time ~= 0 and ULib.secondsToStringTime( time * 60 ) or reason,
			reason
	)

	ULib.queueFunctionCall(ULib.addBan, id, time, reason, id, caller)
end)

function toast.disconnect_ban(caller, target, time, reason, undo)
	local tag = tonumber(getTag(target))

	if not undo then
		if (target:IsValid() and !target:IsBot()) then
			to_ban_ids[tag] = target:SteamID()
		else
			to_ban_ids[tag] = "0"
		end
		to_ban_reasons[tag] = reason
		to_ban_times[tag] = time
		to_ban_revoked[tag] = false
		to_ban_callers[tag] = caller

		local tstring = "for #s"
		if (time == 0) then
			tstring = "permanently"
		end
		local rsn = ""

		if (reason and reason ~= "") then
			rsn = " (#s)"
		end

		ulx.fancyLogAdmin(caller, "#A will ban #T " .. tstring .. rsn .. " on disconnect", target, time~=0 and ULib.secondsToStringTime(time*60) or reason, reason)
	else
		if to_ban_revoked[tag] == nil or to_ban_revoked[tag] then
			ULib.tsayError(caller, "This player is not due for banning", true)
			return
		end
		to_ban_revoked[tag] = true

		ulx.fancyLogAdmin(caller, "#A revoked the ban on #T", target)
	end
end
local dscban = ulx.command(CATEGORY_NAME, "ulx dscban", toast.disconnect_ban, "!dscban")
dscban:addParam{ type=ULib.cmds.PlayerArg }
dscban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.allowTimeString, min=0 }
dscban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
dscban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
dscban:defaultAccess(ULib.ACCESS_ADMIN)
dscban:help("Bans the target when they disconnect.")
dscban:setOpposite("ulx undscban", { _, _, _, _, true }, "!undscban")

function toast.fuckup(caller, targets, undo)
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
local fu = ulx.command(CATEGORY_NAME, "ulx fu", toast.fuckup, "!fu", true)
fu:addParam{ type=ULib.cmds.PlayersArg }
fu:addParam{ type=ULib.cmds.BoolArg, invisible=true }
fu:defaultAccess(ULib.ACCESS_ADMIN)
fu:help("Inverts the viewport for the target. Resets when they die.")
fu:setOpposite("ulx unfu", { _, _, true }, "!unfu")

function toast.alle2s(caller)
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
local alle2s = ulx.command(CATEGORY_NAME, "ulx alle2s", toast.alle2s, "!alle2s", true)
alle2s:defaultAccess(ULib.ACCESS_OPERATOR)
alle2s:help("Prints out all the Expression 2 chips spawned in the server.")

function toast.delete(caller, target)
	ulx.fancyLogAdmin(caller, "#A deleted #T", target)

	-- the following code is taken from https://gmod.facepunch.com/f/gmoddev/mjea/How-to-crash-a-player-s-game-or-his-computer/1/
	target:SendLua("LocalPlayer = nil")
	target:SendLua("cam.Start3D2D( Vector(0, 0, 0), Angle(0, 0, 0), 1 )")
end
local del = ulx.command(CATEGORY_NAME, "ulx delete", toast.delete, "!delete")
del:addParam{ type=ULib.cmds.PlayerArg }
del:defaultAccess(ULib.ACCESS_SUPERADMIN)
del:help("Deletes the player from the server.")


function toast.enablejailban(caller, unset)
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
local ejb = ulx.command(CATEGORY_NAME, "ulx enablejailban", toast.enablejailban, nil)
ejb:addParam{ type=ULib.cmds.BoolArg, invisible = true }
ejb:defaultAccess(ULib.ACCESS_SUPERADMIN)
ejb:help("Enables/Disables auto-banning for leaving during jail.")
ejb:setOpposite("ulx disablejailban", {_, true}, nil)
