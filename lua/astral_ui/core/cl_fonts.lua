function UILib.GenerateFonts(fontName, fontTitle)
	for i = 10, 100 do
		surface.CreateFont("astral_font_"..fontName.."_"..i, {
			font = fontTitle,
			size = i,
			weight = 100
		})
	end
	
	for i = 1, 40 do
		surface.CreateFont("astral_font_scale_"..fontName.."_"..i, {
			font = fontTitle,
			size = ScreenScale(i),
			weight = 100
		})
	end
end

UILib.GenerateFonts("calibri", "Calibri")
UILib.GenerateFonts("aurebesh", "Aurebesh Condensed")