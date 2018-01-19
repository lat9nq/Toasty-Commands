local CATEGORY_NAME = "Toasty"
local joins = {}
local file_name = "toast_jban.txt"
local toast = {}

function toast.jban(caller)
	local key = ""
	local c = ""
	math.randomseed((SysTime() - math.floor(SysTime()))*1000000)
	for i=1, 64 do
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
	--print(key)

	caller:SetNWInt(key, table.Count(joins))
	for i, x in pairs(joins) do
		local str = util.TableToJSON(x)
		caller:SetNWString(key .. tostring(i), str)
	end
end
local jban = ulx.command(CATEGORY_NAME, "ulx jban", toast.jban, "!jban", true)
jban:defaultAccess(ULib.ACCESS_ADMIN)
jban:help("Allows banning anyone who joined in the last 24 hours")

local function player_join(ply)
	if not ply:IsValid() then
		return
	end
	local ip = ply:IPAddress()
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

hook.Add("InitPostEntity", "LoadJBanRecords", function()
			local f = file.Open(file_name, "r", "DATA")

			local size = f:Size()
			joins = util.JSONToTable(f:Read(size))
		end)

