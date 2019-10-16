local ban_length = 7*24*60  --one week, set to 0 for perma

local cvars = {
	sv_allowcslua = 0,
	mat_wireframe = 0,
	sv_cheats = 0
}

local ply_commands = {}

-- don't want angery server owners, so it checks for consistency, not conventions like above
for i,j in pairs(cvars) do
	cvars[i] = GetConVar(i):GetInt()
	print(tostring(i) .. " = " .. tostring(cvars[i]))
end

local function new_cmmnd()
	local com_name = ""
	for x = 1, math.random(8,24) do
		local c
		if (math.random(0,1) == 1) then
			c = string.char(math.random(48,57))
		else
			c = string.char(math.random(65,70))
		end
		com_name = com_name .. c
	end

	--print(com_name)

	concommand.Add(com_name, function(ply, cmd, args, argStr)
		local allowed = false
		for ply_name, cmd_name in pairs(ply_commands) do
			if (cmd_name == cmd) then
				allowed = true
				break
			end
		end
		if (allowed) then
			local str = "Manipulated console variable " .. argStr
			if (not ply:IsAdmin()) then
				ulx.ban(ply, ply, ban_length, str)
			else
				ULib.tsayError(nil, ply:GetName() .. " manipulated console variable " .. argStr)
			end
			--print(ply:GetName() .. ": " .. str)
		end
	end)

	return com_name
end
local ind = 1

local function ensure_consistency()
	ind = (ind % player.GetCount()) + 1
	local ply = player.GetAll()[ind]
	local com_name = ply_commands[ply:SteamID()]

	for cvar, val in pairs(cvars) do
		local str = "if GetConVar(\"" .. tostring(cvar) .. "\"):GetInt() != " .. GetConVar(cvar):GetInt() .. " then RunConsoleCommand(\"" .. com_name .. "\", \"" .. tostring(cvar) .. "\") end"
		ply:SendLua(str)
		--print(str)
	end
end

local timer_name = "TAM_Check_CVars"

local function update_timer(count)
	timer.Remove(timer_name)
	if (count > 0) then
		timer.Create(timer_name, 5.000/count, 0, ensure_consistency)
	end
end

hook.Add("PlayerInitialSpawn", "TAM_UpdateCvarTimer_Connect", function(ply)
	update_timer(player.GetCount())
	ply_commands[player:SteamID()] = new_cmmnd()
end)

hook.Add("PlayerDisconnected", "TAM_UpdateCvarTimer_Disconnect", function(ply)
	update_timer(player.GetCount() - 1)
end)


update_timer(player.GetCount())
