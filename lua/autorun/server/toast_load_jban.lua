include("ulx/modules/sh/toast_jban.lua")
local filename = "toast_jban.txt"
local message_name = "toast_jban"

local function load_jban_records(past)
	local f = file.Open("toast_jban.txt", "r", "DATA")
	if not f then return end

	local size = f:Size()
	if not joins then
		print("load_jban_records.lua: joins doesn't exist!")
		return
	end
	joins = util.JSONToTable(f:Read(size))
	f:Close()

	if not past then
		util.AddNetworkString(message_name)
	end
end

hook.Add("InitPostEntity", "LoadJBanRecords", load_jban_records)
concommand.Add("reloadjban", function()
	load_jban_records(true)
end)

