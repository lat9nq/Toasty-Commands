disconnect_jail_list = {}
toast_auto_ban = false
toastab_filename = "toast_auto_ban.txt"

local last_ran = 0

local function getTag(ply)
	if (!(ply:IsValid() and not ply:IsBot())) then
		return "0"
	end
	local id = ply:SteamID()
	local idt = string.Explode(":", id)
	return idt[2] .. idt[3]
end

local ind = 0

local function clk()
	last_ran = SysTime()
	ind = (ind % player.GetCount()) + 1
	local ply = player.GetAll()[ind]
	if (not ply:IsValid()) then
		return
	end
	if (ply.jail) then
		ply.toastjail = 1
	elseif (ply.toastjail and not ply.jail) then
		ply.toastjail = nil
	end
end

local my_timer = "check_jail"
local delay = 1.0

local function updateTabTimer(count)
	if (count == 0) then
		timer.Remove(my_timer)
	else
		if (timer.Exists(my_timer)) then
			timer.Adjust(my_timer, delay/count, 0, clk)
		else
			timer.Create(my_timer, delay/count, 0, clk) 
		end
	end
end

local loaded = false

local function load_tab()
	if not loaded then
		loaded = true
	else
		return
	end

	local f = file.Open(toastab_filename, "r", "DATA")

	if not f then --if the file doesnt exist, write it
		f = file.Open(toastab_filename, "w", "DATA")
		f:Write("0")
		f:Close()
		return
	end

	local r = f:Read(1) --else, decide if we are allowing auto-banning
	if (r == "0") then
		toast_auto_ban = false
	else
		toast_auto_ban = true
	end
	f:Close()
end

--updateTabTimer(player.GetCount())
hook.Add("InitPostEntity", "load_toast_auto-ban", function()
	print("TAB: Loading...")
	load_tab()

	print("TAB: Adding disconnect hook...")
	hook.Add("PlayerDisconnected", "DidTheyLeaveFromJail", function(ply)
		--print("meow")
		if (ply.toastjail) and ply:IsAdmin() then
			local msg = ply:GetName() .. "<" .. ply:SteamID() .. "> has left the server while jailed!"
			ULib.tsay(nil, msg)
			print(msg)

			if (toast_auto_ban) then
				local tag = getTag(ply)

				disconnect_jail_list[tag] = SysTime()
			end
		end

		updateTabTimer(player.GetCount() - 1)
	end)

	print("TAB: Adding connect hook...")
	hook.Add("PlayerInitialSpawn", "IsJailRecon", function(ply)
		updateTabTimer(player.GetCount())
		if (toast_auto_ban) then
			local tag = getTag(ply)
			local dsctime = disconnect_jail_list[tag]
			if (not dsctime) then return end
			local diff = SysTime() - dsctime
			if (diff < 86400) then
				ulx.ban(ply, ply, math.ceil((86400 - diff)/60), "Reconnected to evade jail.")
				disconnect_jail_list[tag] = nil
			end
		end
	end)
	print("TAB: Done!")
end)

concommand.Add("reload_tab", load_tab)
concommand.Add("jailstat", function(caller)
	local str = "last ran " .. tostring(SysTime() - last_ran) .. " seconds ago\ntoast_auto_ban: " .. tostring(toast_auto_ban)
	if not caller:IsValid() then
		print(str)
	else
		caller:PrintMessage(HUD_PRINTCONSOLE, str)
	end
end)

--~~~~~~ From toast sort

hook.Add("PlayerSay", "toastSort", function(ply, strText, bTeam)
	if (ply.sort and not ply:GetNWBool("ulx_gimped") and not ply:GetNWBool("ulx_muted")) then
		local result = ""
		local c = string.char(0)
		for i = 32, 126 do
			c = string.char(i)
			for j = 1, string.len(strText) do
				local x = string.sub(strText, j, j)
				if (c == x) then
					result = result .. x
				end
			end
		end
		return result
	end
end)

