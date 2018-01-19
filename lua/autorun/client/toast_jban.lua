--[[
	toast_jban.lua
	Lua

	Toast Unlimited
	17 January 2018

	The purpose of this file is to server as a base for the jban
	feature in a coming update to Toasty Commands.
	
	jban is a ulx module that will allow the admin (or anyone with
	access to it) to view the join records of the server, and then ban
	accordingly when necessary.

	If you are familiar with dban from Cobalt77's Custom ULX Commands,
	then you have a good idea of what I'm trying to do. In fact, I hope
	jban can serve as a sufficient replacement for dban.
]]


concommand.Add("toast_jban", function(caller, cmd, args)
	if (!caller:IsAdmin() or !caller:IsValid()) then
		return
	end
	local key = args[1]
	timer.Create("load_jban", 0.5, 1, function()
		local jban_frame = vgui.Create("DFrame")
		jban_frame:SetTitle("JBan")
		jban_frame:SetSize(640, 480)
		jban_frame:Center()
		jban_frame:SetSizable(false)
		jban_frame:SetDraggable(false)
		jban_frame:MakePopup()

		local list = vgui.Create("DListView", jban_frame)
		list:Dock(FILL)
		list:SetMultiSelect(false)
		list:AddColumn("id")
		list:AddColumn("SteamID")
		list:AddColumn("Name")
		list:AddColumn("Last Joined")
		list:AddColumn("IP Address")

		local count = caller:GetNWInt(key)
		--print(count)
		--print(key)

		local record = {}

		for i=1, count do
			record = util.JSONToTable(caller:GetNWString(key .. tostring(i)))
			--print(":" .. caller:GetNWString(key .. i))
			list:AddLine(i, record.id, record.name, record.join_time_s, record.ip)
		end

		list:SortByColumn(4, true)

		list.OnRowRightClick = function(_, line_num, dline_bad)
			local menu = vgui.Create("DMenu")
			local dline = list:GetLine(line_num)
			local id = dline:GetValue(1)
			record = util.JSONToTable(caller:GetNWString(key..tostring(id)))

			local opensp = menu:AddOption("Open Steam Profile", function()
						local id64 = util.SteamIDTo64(record.id)
						gui.OpenURL("http://steamcommunity.com/profiles/"..id64)
					end)
			opensp:SetIcon("icon16/link.png")

			local function create_ban_frame(id_banning)
				local banframe = vgui.Create("DFrame")
				banframe:SetSize(256, 128)
				banframe:Center()
				if (id_banning) then
					banframe:SetTitle("Ban ID " .. record.id)
				else
					banframe:SetTitle("Ban IP " .. record.ip)
				end
				banframe:SetDraggable(true)
				banframe:SetSizable(false)
				banframe:MakePopup()

				local time_entry = vgui.Create("DTextEntry", banframe)
				time_entry:SetPos(5,30)
				time_entry:SetSize(246, 25)
				time_entry:SetText("minutes")

				local reason_entry = vgui.Create("DTextEntry", banframe)
				reason_entry:SetPos(5,60)
				reason_entry:SetSize(246, 25)
				if (id_banning) then
					reason_entry:SetText("reason")
				else
					reason_entry:SetText("No reason with IP Ban")
				end
				reason_entry:SetEnabled(id_banning)

				local ban_button = vgui.Create("DButton", banframe)
				ban_button:SetText("Ban")
				ban_button:SetPos(5, 90)
				ban_button:SetSize(246, 25)
				ban_button.DoClick = function()
					if (id_banning) then
						RunConsoleCommand("ulx", "banid", record.id, time_entry:GetValue(), reason_entry:GetValue())
					else
						RunConsoleCommand("ulx", "banip", record.ip, time_entry:GetValue())
					end
					banframe:Close()
				end
			end

			local banid = menu:AddOption("ULX Banid", function()
						create_ban_frame(true)
					end)
			banid:SetIcon("icon16/bug_delete.png")

			local copyip = menu:AddOption("Copy IP Address", function()
						SetClipboardText(record.ip)
					end)
			copyip:SetIcon("icon16/page_copy.png")

			local banip = menu:AddOption("ULX Banip", function()
						create_ban_frame(false)
					end)
			banip:SetIcon("icon16/world_delete.png")

			menu:Open()
		end
	end)
end)

