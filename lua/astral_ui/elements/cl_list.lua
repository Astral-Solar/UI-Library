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


function UILib.HorizontalScroll(parent)
	local scroll = vgui.Create("DHorizontalScroller", parent)
	scroll:Dock(FILL)
	scroll:SetOverlap(-15)

	scroll.btnLeft.Paint = nil
	scroll.btnRight.Paint = nil


	return scroll
end

function UILib.VerticalScroll(container)
	container:InvalidateParent(true)

	local column = vgui_create("DScrollPanel", container)
	column:Dock(FILL)
	column:DockPadding(5, 5, 5, 5)
	column.Paint = nil

	column.master = container.master
	function column:Paint(w, h)
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
	
	local sbar = column:GetVBar()
	sbar:SetWide(0)
	sbar:SetHideButtons(true)

	return column
end