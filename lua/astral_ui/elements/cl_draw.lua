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
local white = color(255, 255, 255)
local black = color(0, 0, 0)
local transWhite = color(255, 255, 255, 55)
local transBlack = color(0, 0, 0, 155)


local sinCache = {}
local cosCache = {}
for i = 0, 360 do
	sinCache[i] = math.sin(math.rad(i))
	cosCache[i] = math.cos(math.rad(i))
end
function UILib.DrawCircle(x, y, r, step)
    local positions = {}

    for i = 0, 360, step do
        table.insert(positions, {
            x = x + cosCache[i] * r,
            y = y + sinCache[i] * r
        })
    end

    return surface.DrawPoly(positions)
end


function UILib.DrawText(text, size, posx, posy, color, align1, align2, font)
	return draw.SimpleText(text or "Sample Text", "astral_font_"..(font or "calibri").."_"..(size or 10), posx or 0, posy or 0, color or black, align1 or TEXT_ALIGN_CENTER, align2 or TEXT_ALIGN_CENTER)
end
function UILib.DrawTextOutlined(text, size, posx, posy, color, align1, align2, thickness, lineColor, font)
	return draw.SimpleTextOutlined(text or "Sample Text", "astral_font_"..(font or "calibri").."_"..(size or 10), posx or 0, posy or 0, color or black, align1 or TEXT_ALIGN_CENTER, align2 or TEXT_ALIGN_CENTER, thickness or 2, lineColor or black)
end
function UILib.DrawScaleText(text, size, posx, posy, color, align1, align2, font)
	return draw.SimpleText(text or "Sample Text", "astral_font_scale_"..(font or "calibri").."_"..(size or 10), posx or 0, posy or 0, color or black, align1 or TEXT_ALIGN_CENTER, align2 or TEXT_ALIGN_CENTER)
end

function UILib.DrawBox(posx, posy, w, h)
		-- Back Plate
		draw.RoundedBox(0, posx, posy, w, h, transBlack)
		-- Top Bar
		draw.RoundedBox(0, posx, posy, w, 5, white)
		-- Bottom Bar
		draw.RoundedBox(0, posx, posy + (h-5), w, 5, white)
		-- Left Bar
		draw.RoundedBox(0, posx, posy + 5, 5, h-10, white)
		-- Right Bar
		draw.RoundedBox(0, posx + (w-5), posy + 5, 5, h-10, white)
end


local blur = Material("pp/blurscreen")
local scrW, scrH = ScrW(), ScrH()
function UILib.DrawBlur(posx, posy, w, h, amount)
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )
	for i = 1, 6 do
		blur:SetFloat('$blur', (i / 6) * (amount ~= nil and amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		
		surface.DrawTexturedRect(posx * -1, posy * -1, ScrW(), ScrH())
	end
end