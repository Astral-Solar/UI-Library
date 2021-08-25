-- Cache
local scrW, scrH = ScrW, ScrH
local vgui_create = vgui.Create
local color = Color
local draw_box = draw.RoundedBox
local surface_setdrawcolor = surface.SetDrawColor
local surface_setmaterial = surface.SetMaterial
local surface_drawtexturedrect = surface.DrawTexturedRect
local surface_drawtexturedrectrotated = surface.DrawTexturedRectRotated
local math_floor = math.floor
local math_round = math.Round
local lerp = Lerp

-- Color cache
local transWhite = color(255, 255, 255, 55)
local transBlack = color(0, 0, 0, 155)

-- Basic panels
function UILib.Panel(parent)
	local pnl = vgui.Create("DPanel", parent)
	function pnl:Paint(w, h)
		-- Back Plate
		draw.RoundedBox(0, 0, 0, w, h, transBlack)
		-- Top Bar
		draw.RoundedBox(0, 0, 0, w, 5, transWhite)
		-- Bottom Bar
		draw.RoundedBox(0, 0, h-5, w, 5, transWhite)
		-- Left Bar
		draw.RoundedBox(0, 0, 5, 5, h-10, transWhite)
		-- Right Bar
		draw.RoundedBox(0, w-5, 5, 5, h-10, transWhite)
	end
	pnl:DockPadding(10, 10, 10, 10)

	return pnl
end
function UILib.ShadowPanel(parent)
	local pnl = vgui.Create("DPanel", parent)
	function pnl:Paint(w, h)
		-- Back Plate
		draw.RoundedBox(0, 0, 0, w, h, transBlack)
	end

	return pnl
end

-- Model holding weapon
function UILib.ModelHoldingWeapon(parent, mdl, weaponModel)
	local model = vgui.Create("DModelPanel", parent)
	model:Dock(FILL)
	model:SetModel(mdl)

	function model:LayoutEntity(Entity)
		self:RunAnimation()
	end 

	local boneTarget = model.Entity:GetBonePosition(model.Entity:LookupBone("ValveBiped.Bip01_Spine"))
	model:SetLookAt(boneTarget)
	model:SetCamPos(boneTarget-Vector(-40, 0, -5))

	if weaponModel then
		function model:PostDrawModel(ent)
			if ent.wep then
				local pos, ang = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_R_Hand"))
				ang:RotateAroundAxis(ang:Forward(), 180)
				ang:RotateAroundAxis(ang:Up(), 10)
				ent.wep:SetPos(pos + (ang:Forward() * 3) + (ang:Up() * 2))
				ent.wep:SetAngles(ang)
				ent.wep:DrawModel()
				return
			end
	
			ent.wep = ClientsideModel(weaponModel)
			ent.wep:AddEffects(EF_BONEMERGE)
			ent.wep:SetParent(ent, ent:LookupBone("ValveBiped.Bip01_R_Hand"))
		end
	end

	return model
end

-- Draw basic text
function UILib.TextPanel(container, text, size, locAlign, font)
	local panel = vgui.Create("DPanel", container)
	panel:SetWide(container:GetWide())
	panel:Dock(TOP)
	panel:SetTall(size or 40)
	panel.text = text
	panel.color = color_white
	panel.Paint = function(self, w, h)
		UILib.DrawText(self.text, size or 40, (locAlign == TEXT_ALIGN_LEFT and 5) or (locAlign == TEXT_ALIGN_RIGHT and w-5) or w/2, h/2, self.color, locAlign or TEXT_ALIGN_CENTER, nil, font)
	end

	return panel
end

-- Draw basic text
function UILib.TextPanelTranslation(container, text, size, subSize, locAlign, font)
	local panel = vgui.Create("DPanel", container)
	panel:SetWide(container:GetWide())
	panel:Dock(TOP)
	panel:SetTall(((size + subSize) + 20) or 40)
	panel.text = text
	panel.color = color_white
	panel.Paint = function(self, w, h)
		UILib.DrawText(self.text, size or 40, (locAlign == TEXT_ALIGN_LEFT and 5) or (locAlign == TEXT_ALIGN_RIGHT and w-5) or w/2, h/2 + 5, self.color, locAlign or TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "aurebesh")
		UILib.DrawText(self.text, subSize or 20, (locAlign == TEXT_ALIGN_LEFT and 5) or (locAlign == TEXT_ALIGN_RIGHT and w-5) or w/2, h/2 - 5, self.color, locAlign or TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, font)
	end

	return panel
end