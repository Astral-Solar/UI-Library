-- Cache
local color = Color
local isvalid = IsValid
local draw_box = draw.RoundedBox
local hook_remove = hook.Remove
local hook_add = hook.Add
local timer_simple = timer.Simple
local table_sorybymember = table.SortByMember
local _pairs = pairs
local scrw, scrh = ScrW, ScrH
local player_getall = player.GetAll

-- Color cache
local white = color(255, 255, 255)


function UILib.Scoreboard()
	if IsValid(UILib.ScoreboardPanel) then
		UILib.ScoreboardPanel:Remove()
		return
	end

	local frame = UILib.Frame("background_space")
	UILib.ScoreboardPanel = frame
	frame:SetSize(scrh() * 0.8, scrh() * 0.8)
	frame:Center()
	frame:DockPadding(10, 10, 10, 10)
	frame.Paint = nil

	local shell = vgui.Create("DPanel", frame)
	shell.Paint = nil
	shell:Dock(FILL)

	local header = UILib.Panel(shell)
	header:Dock(TOP)
	header:DockMargin(0, 0, 0, 10)
	header:SetTall(50)
		local title = UILib.TextPanel(header, GetHostName(), 30, TEXT_ALIGN_CENTER, "orbitron")

	local footer = UILib.Panel(shell)
	footer:Dock(BOTTOM)
	footer:DockMargin(0, 10, 0, 0)
	footer:SetTall(45)
		local version = UILib.TextPanel(footer, "Version: "..CURRENT_VERSION, 25, TEXT_ALIGN_LEFT, "orbitron")
		version:Dock(LEFT)
		version:SetWide(footer:GetWide() * 0.5)
		local players = UILib.TextPanel(footer, "Players: "..player.GetCount().."/"..game.MaxPlayers(), 25, TEXT_ALIGN_RIGHT, "orbitron")
		players:Dock(RIGHT)
		players:SetWide(footer:GetWide() * 0.5)

	function footer:PerformLayout()
		players:SetWide(footer:GetWide() * 0.5)
		version:SetWide(footer:GetWide() * 0.5)
	end

	local cats = {}
	local registeredCats = {}
	for k, v in _pairs(RPExtraTeams) do
		local plys = team.GetPlayers(k)
		if table.IsEmpty(plys) then continue end

		if not registeredCats[v.category] then
			registeredCats[v.category] = table.insert(cats, {name = v.category, plys = {}})
		end

		for _, p in ipairs(plys) do
			table.insert(cats[registeredCats[v.category]].plys, p)
		end
	end

	local column = UILib.VerticalScroll(shell)
	column:Dock(FILL)
	column.Paint = nil

	for _, cat in ipairs(cats) do
		local catShell =  UILib.Panel(column)
		catShell:Dock(TOP)
		catShell:SetTall(50)
		catShell:DockPadding(5, 5, 5, 5)
		catShell:DockMargin(0, 0, 0, 10)

		local title = UILib.TextPanel(catShell, cat.name, 40, TEXT_ALIGN_CENTER, "orbitron")

		for k, v in ipairs(cat.plys) do
			local pnl = UILib.ShadowPanel(catShell)
			pnl:Dock(TOP)
			pnl:DockMargin(0, 5, 0, 5)
			pnl:SetTall(50)
	
			local avatar = vgui.Create("AvatarImage", pnl)
			avatar:Dock(LEFT)
			avatar:SetSize(pnl:GetTall(), pnl:GetTall())
			avatar:SetPlayer(v, 184)
	
			local name = UILib.TextPanel(pnl, v:Name(), 30, TEXT_ALIGN_LEFT, "orbitron")
			name:Dock(FILL)
			name:DockMargin(5, 0, 0, 0)
			local job = UILib.TextPanel(pnl, team.GetName(v:Team()), 30, TEXT_ALIGN_RIGHT, "orbitron")
			job:Dock(RIGHT)
			job:DockMargin(0, 0, 5, 0)
	
			local btn = vgui.Create("DButton", pnl)
			btn:SetText("")
			btn.Paint = nil
			btn.DoClick = function()
				local card = UILib.Frame()
				card:SetSize(scrh() * 0.5, scrh() * 0.5)
				card:Center()
				card.Paint = nil
	
				local shell = UILib.Panel(card)
				shell:Dock(FILL)
	
				local name = UILib.TextPanel(shell, v:Name(), 60, TEXT_ALIGN_CENTER, "orbitron")
				local playtimeTotal = UILib.TextPanel(shell, "Playtime: 120d 13h 44m | 2h 13m", 30, TEXT_ALIGN_CENTER, "orbitron")
	
				timer.Simple(2, function()
					card:Remove()
				end)
			end
	
			function pnl:PerformLayout()
				job:SetWide(pnl:GetWide()*0.3)
				btn:SetSize(pnl:GetWide(), pnl:GetTall())
			end
		end
	end

	function column:PerformLayout()
		for k, v in ipairs(self:GetChildren()[1]:GetChildren()) do
			v:SizeToChildren(true, true)
		end
		--for k, v in pairs(self:GetChildren())
		--catShell:SizeToChildren(true, true)
	end
end


-- Make it all work
timer_simple(0.1, function()
	hook_remove("ScoreboardHide", "FAdmin_scoreboard")
	hook_remove("ScoreboardShow", "FAdmin_scoreboard")
end)

hook_add("Initialize", "RemoveGamemodeFunctions", function()
	GAMEMODE.ScoreboardShow = nil
	GAMEMODE.ScoreboardHide = nil
end)

hook_add("ScoreboardShow", "DarkRP.custom.scoreboard.show", function()
	UILib.Scoreboard()
end)

hook_add("ScoreboardHide", "DarkRP.custom.scoreboard.hide", function()
	UILib.Scoreboard()
end)

concommand.Add("astral_scoreboard", function()
	UILib.Scoreboard()
end)