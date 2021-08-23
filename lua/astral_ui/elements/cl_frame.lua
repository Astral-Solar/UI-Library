-- Cache
local scrW, scrH = ScrW, ScrH
local vgui_create = vgui.Create
local draw_box = draw.RoundedBox
local color = Color
local surface_setdrawcolor = surface.SetDrawColor
local surface_setmaterial = surface.SetMaterial
local surface_drawtexturedrect = surface.DrawTexturedRect
local surface_drawtexturedrectrotated = surface.DrawTexturedRectRotated

-- Color cache
local transWhite = color(255, 255, 255, 55)
local transBlack = color(0, 0, 0, 155)

-- Create a base frame
function UILib.Frame(background)
	-- Base frame
	local frame = vgui_create("DFrame")
	frame:SetSize(scrW()*0.5, scrH()*0.5)
	frame:Center()
	if not noPopup then
		frame:MakePopup()
	end
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:DockPadding(0, 0, 0, 0)

	frame.header = string.upper(title or "Set my title please :P")
	frame.headerColor = frameColor or headerDefault
	frame.master = frame

	function frame:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(AstralLib.Image.GetMat(background or "background_whitebars"))
		surface.DrawTexturedRect(0, 0, w, h)
	end 

	return frame
end