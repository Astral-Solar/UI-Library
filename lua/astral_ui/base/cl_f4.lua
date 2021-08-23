util.PrecacheModel("models/sw_battlefront/weapons/dc15s_carbine.mdl")
util.PrecacheModel("models/weapons/w_rif_m4a1_silencer.mdl")
local transBlack = Color(0, 0, 0, 155)
local transWhite = Color(255, 255, 255, 55)
local purple = Color(95, 37, 122)

-- Client database prep
local function savePreset(jobModel, skinID, groups)
	if not sql.TableExists("astral_bodygroups") then
		sql.Query("CREATE TABLE astral_bodygroups(model TEXT PRIMARY KEY, skin INT, groups TEXT)")
	end


	sql.Query(string.format("INSERT OR REPLACE INTO astral_bodygroups(model, skin, groups) VALUES ('%s', %i, '%s');", jobModel, skinID, util.TableToJSON(groups)))
end

local function getPreset(jobModel)
	local preset = sql.Query(string.format("SELECT * FROM astral_bodygroups WHERE model='%s';", jobModel))

	return preset
end


function UILib.HUB()
	local frame = UILib.Frame("background_purpleorbs")
	frame:SetSize(ScrW(), ScrH())
	frame:SetPos(0, 0)

	local padding = frame:GetTall()*0.05

	local buttonShell = UILib.Panel(frame)
	buttonShell:Dock(LEFT)
	buttonShell:DockMargin(padding, padding, 0, padding)
	buttonShell:SetWide(frame:GetWide()*0.25)
	buttonShell.Paint = nil

	local btns = {
		{
			name = "Loadout",
			func = function() end
		},
		{
			name = "Website",
			func = function() end
		},
		{
			name = "Store",
			func = function() end
		},
		{
			name = "Discord",
			func = function() end
		},
		{
			name = "Close",
			func = function()
				frame:Close()
			end
		}
	}

	for k, v in ipairs(btns) do
		local btn = UILib.Button(buttonShell, v.name, v.func)
		btn:SetTall(70)
		btn:DockMargin(0, 10, 0, 0)
	end

	local scroll = UILib.HorizontalScroll(frame)
	scroll:DockMargin(padding, padding, padding, padding)


	for k, v in pairs(RPExtraTeams) do
		local pnl = UILib.Panel(scroll)
		pnl:SetWide(frame:GetWide()*0.25)
		scroll:AddPanel(pnl)

		local model = UILib.ModelHoldingWeapon(pnl, istable(v.model) and v.model[1] or v.model)
		model:SetAnimated(true)

		local oldPaint = model.Paint
		function model.Paint(self, w, h)
			oldPaint(self, w, h)
		end

		local text = UILib.TextPanelTranslation(pnl, v.name, 35, 40)
		text:Dock(BOTTOM)

		local btn = vgui.Create("DButton", pnl)
		btn:SetPos(0, 0)
		btn:SetText("")
		btn.Entity = model.Entity
		btn.Paint = nil

		pnl.Paint = function(self, w, h)
			local clr = btn:IsHovered() and purple or transWhite
			-- Back Plate
			draw.RoundedBox(0, 0, 0, w, h, transBlack)
			-- Top Bar
			draw.RoundedBox(0, 0, 0, w, 5, clr)
			-- Bottom Bar
			draw.RoundedBox(0, 0, h-5, w, 5, clr)
			-- Left Bar
			draw.RoundedBox(0, 0, 5, 5, h-10, clr)
			-- Right Bar
			draw.RoundedBox(0, w-5, 5, 5, h-10, clr)
		end

		btn.DoClick = function()
			UILib.ModelSettings(v)
			frame:Close()
		end

		btn.isAnimating = false
		function btn:Think()
			if btn.isAnimating and not btn:IsHovered() then
				self.Entity:SetSequence(model.Entity:LookupSequence("pose_standing_02"))
				btn.isAnimating = false
				self.Entity:ResetSequenceInfo()
				return
			end

			if btn.isAnimating then return end
			if not btn:IsHovered() then return end


			btn.isAnimating = true
			self.Entity:SetSequence(self.Entity:LookupSequence("pose_standing_04"))
		end 
		function pnl:PerformLayout(w, h)
			btn:SetSize(w, h)
		end
	end
end
function UILib.ModelSettings(jobData, modelKey)
	local frame = UILib.Frame()
	local padding = frame:GetTall()*0.05
	frame:SetSize(ScrW(), ScrH())
	frame:SetPos(0, 0)
	frame:ShowCloseButton(true)
	frame:DockMargin(padding, padding, padding, 0)

	local shell = UILib.Panel(frame)
	shell:Dock(FILL)
	shell:DockMargin(padding, padding, padding, 0)
	shell.Paint = nil

	local model = UILib.ModelHoldingWeapon(shell, istable(jobData.model) and jobData.model[modelKey or 1] or jobData.model, "models/sw_battlefront/weapons/dc15s_carbine.mdl")
	model:SetAnimated(true)
	model:Dock(FILL)
	model:DockMargin(0, 0, 0, -10)
	model:SetWide(frame:GetWide() * 0.5)
	local boneTarget = model.Entity:GetBonePosition(model.Entity:LookupBone("ValveBiped.Bip01_Head1"))
	model:SetLookAt(boneTarget-Vector(0, 0, 7))
	model:SetCamPos(boneTarget-Vector(-30, 0, 5))
	model.Entity:SetSequence(model.Entity:LookupSequence("idle_passive"))

	-- Model Changer
	local modelControls = UILib.Panel(model)
	modelControls:Dock(BOTTOM)
	modelControls:DockMargin(0, 0, 0, padding)
	modelControls:SetTall(60)
	modelControls.Paint = nil
	if istable(jobData.model) and (table.Count(jobData.model) > 1) then
	
		if modelKey and (modelKey > 1) then
			-- Back model
			local back = UILib.ButtonBox(modelControls, "<", function()
				frame:Remove()
				UILib.ModelSettings(jobData, modelKey - 1)
			end)
			back:Dock(LEFT)
			back:DockMargin(model:GetWide()*0.4, 0, 0, 0)
		end
		if (modelKey or 1) < table.Count(jobData.model) then
			-- Forward model
			local forward = UILib.ButtonBox(modelControls, ">", function()
				frame:Remove()
				UILib.ModelSettings(jobData, (modelKey or 1) + 1)
			end)
			forward:Dock(RIGHT)
			forward:DockMargin(0, 0, model:GetWide()*0.4, 0)
		end
	end 
	-- HUB button
	local HUB = UILib.ButtonBox(modelControls, "HUB", function()
		frame:Remove()
		UILib.HUB()
	end)
	HUB:Dock(RIGHT)
	HUB:DockMargin(0, 0, 0, 0)
	HUB:SetWide(100)

	local function processChange()
		local skinID = model.Entity:GetSkin()
		local bodygroups = {} 
		for k, v in ipairs(model.Entity:GetBodyGroups()) do
			if v.num <= 1 then continue end
			bodygroups[v.id] = model.Entity:GetBodygroup(v.id)
		end

		savePreset(model.Entity:GetModel(), skinID, bodygroups)
	end


	local presetModelData = getPreset(model.Entity:GetModel())
	local targetData
	if presetModelData and presetModelData[1] then
		targetData = presetModelData[1]

		model.Entity:SetSkin(targetData.skin)
		targetData.groups = util.JSONToTable(targetData.groups)
		for k, v in pairs(targetData.groups) do
			model.Entity:SetBodygroup(k, v)
		end
	end

	local columnShell = UILib.Panel(shell)
	columnShell.Paint  = nil
	columnShell:SetWide(frame:GetWide()*0.4)
	columnShell:DockMargin(0, 0, 0, padding)
	columnShell:Dock(LEFT)

	local column = UILib.VerticalScroll(columnShell)
	column:Dock(FILL)

	local title = UILib.TextPanelTranslation(columnShell, jobData.name, 55, 50, TEXT_ALIGN_LEFT)
	title:Dock(TOP)
	title:DockMargin(10, 10, 0, -10)

	local skins
	if model.Entity:SkinCount() > 1 then
		skins = vgui.Create("DPanel", column)
		skins:Dock(TOP)
		skins:SetTall(120)
		skins.Paint = nil

		skins.text = UILib.TextPanelTranslation(skins, "SKIN", 35, 30, TEXT_ALIGN_LEFT)
		skins.text:DockMargin(20, 20, 20, 20)
		skins.text:Dock(TOP)

		skins.slider = UILib.Slider(skins, 0, model.Entity:SkinCount() - 1)
		skins.slider:Dock(BOTTOM)

		function skins.slider:OnChange(newVal)
			model.Entity:SetSkin(newVal)
			processChange()
		end
	end

	local bodyGroups = {}
	for k, v in ipairs(model.Entity:GetBodyGroups()) do
		if v.num <= 1 then continue end

		local bodygroup = vgui.Create("DPanel", column)
		table.insert(bodyGroups, bodygroup)
		bodygroup:Dock(TOP)
		bodygroup:SetTall(120)
		bodygroup.Paint = nil

		bodygroup.text = UILib.TextPanelTranslation(bodygroup, string.upper(v.name), 35, 30, TEXT_ALIGN_LEFT)
		bodygroup.text:DockMargin(20, 20, 20, 20)
		bodygroup.text:Dock(TOP)

		bodygroup.slider = UILib.Slider(bodygroup, 0, v.num-1)
		bodygroup.slider:Dock(BOTTOM)

		function bodygroup.slider:OnChange(newVal)
			model.Entity:SetBodygroup(v.id, newVal)
			processChange()
		end
	end


	local deploy = UILib.ButtonBox(columnShell, "Deploy", function()
		frame:Close()

		net.Start("Astral:UILib:ChangeLook")
			-- Job
			net.WriteString(jobData.command)
			-- Model
			net.WriteUInt(modelKey or 1, 6)
			-- Skin
			net.WriteUInt(model.Entity:GetSkin(), 6)
			-- Bodygroups
			local bodygroups = {}
			for k, v in ipairs(model.Entity:GetBodyGroups()) do
				if v.num <= 1 then continue end
				bodygroups[v.id] = model.Entity:GetBodygroup(v.id)
			end

			net.WriteUInt(table.Count(bodygroups), 6)
			for k, v in pairs(bodygroups) do
				net.WriteUInt(k, 6)
				net.WriteUInt(v, 6)
			end
		net.SendToServer()

		RunConsoleCommand("say", "/"..jobData.command)
	end)
	deploy:DockMargin(0, 10, 0, 0)
	deploy:Dock(BOTTOM)
	deploy:SetTall(45)
end

timer.Simple(2, function()
	GAMEMODE.ShowSpare2 = UILib.HUB
end) 

concommand.Add("astral_hub", function()
	UILib.HUB()
end)

hook.Add("XYZPostImageLoad", "Astral:UILib:ShowHUB", function()
	UILib.HUB()
end)