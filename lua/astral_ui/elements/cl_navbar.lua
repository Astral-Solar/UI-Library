-- Cache
local vgui_create = vgui.Create
local draw_box = draw.RoundedBox
local surface_setdrawcolor = surface.SetDrawColor
local surface_setmaterial = surface.SetMaterial
local surface_drawtexturedrect = surface.DrawTexturedRect
local surface_drawtexturedrectrotated = surface.DrawTexturedRectRotated
local color = Color

-- Color cache
local background = color(18, 18, 18)
local outline = color(31, 31, 31)
local white = color(222, 222, 222)
local headerDefault = color(2, 108, 254)
local headerShader = color(0, 0, 0, 55)

-- Material cache
local gradientDown = Material("gui/gradient_down")
local gradientUp = Material("gui/gradient_up")
local gradientMain = Material("gui/gradient")
local gradientCenter = Material("gui/center_gradient")
