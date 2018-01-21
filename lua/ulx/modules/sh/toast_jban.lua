toast = {}
joins = {}
local file_name = "toast_jban.txt"
local CATEGORY_NAME = "Toasty"
local message_name = "toast_jban"

local function num_to_ascii(s)
	local c
	local str = ""
	for i = 1, string.len(s) do
		c = string.sub(s, i, i)
		str = str .. string.char(65 + tonumber(c))
	end
	return str
end

function toast.jban(caller)
	--[[local key = ""
	local c = ""
	math.randomseed((SysTime() - math.floor(SysTime()))*1000000)
	for i=1, 32 do
		if (math.random(0,2) == 1) then
			c = string.char(math.random(65,90))
		elseif (math.random(0,1) == 1) then
			c = string.char(math.random(97,122))
		else
			c = string.char(math.random(48,57))
		end
		key = key .. c
	end
	caller:SendLua("RunConsoleCommand(\"toast_jban\", \"" .. key .. "\")")
	]]
	net.Start(message_name)
	net.WriteString(util.TableToJSON(joins))
	--PrintTable(joins)
	net.Send(caller)
end
local jban = ulx.command(CATEGORY_NAME, "ulx jban", toast.jban, "!jban", true)
jban:defaultAccess(ULib.ACCESS_ADMIN)
jban:help("Allows banning anyone who joined in the last 24 hours")

local function player_join(ply)
	if not ply:IsValid() then
		return
	end
	local ip = ply:IPAddress()
	if string.find(ip, ":") then
		ip = string.sub(ip, 1, string.find(ip, ":")-1)
	end
	local name = ply:GetName()
	local id = ply:SteamID()
	local join_time = os.time()
	local join_time_s = os.date("%y/%m/%d %H:%M:%S", join_time)
	
	local record = {}
	record.ip = ip
	record.name = name
	record.id = id
	record.join_time = join_time
	record.join_time_s = join_time_s

	local found = false
	for i, x in pairs(joins) do
		if (x.id == id) then
			table.remove(joins, i)
			table.insert(joins, record)
			found = true
			break
		end
	end
	if not found then
		table.insert(joins, record)
	end


	local f = file.Open(file_name, "w", "DATA")

	local str = ""
	for _, x in pairs(joins) do
		if (x.join_time + 86400 < os.time()) then
			table.remove(joins, _)
		end
	end

	local out = util.TableToJSON(joins)
	f:Write(out)
	f:Close()
end

hook.Add("PlayerInitialSpawn", "JBan_Register_Spawn", player_join)

