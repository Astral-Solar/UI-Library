-- Cache
local scrW, scrH = ScrW, ScrH
local vgui_create = vgui.Create
local color = Color
local draw_box = draw.RoundedBox
local surface_setdrawcolor = surface.SetDrawColor
local surface_setmaterial = surface.SetMaterial
local draw_notexture = draw.NoTexture
local surface_drawtexturedrect = surface.DrawTexturedRect
local surface_drawtexturedrectrotated = surface.DrawTexturedRectRotated
local surface_drawpoly = surface.DrawPoly
local math_round = math.Round
local math_clamp = math.Clamp
local lerp = Lerp

-- Color cache
local transWhite = color(255, 255, 255, 55)
local transBlack = color(0, 0, 0, 155)
local white = color(255, 255, 255)
local purple = color(95, 37, 122)

-- Material cache
local gradientDown = Material("gui/gradient_down")
local gradientUp = Material("gui/gradient_up")
local gradientMain = Material("gui/gradient")
local gradientCenter = Material("gui/center_gradient")

local gradientSize = 10


function UILib.Button(container, text, callback)
	if not IsValid(container) then return end

	local buttonInput = vgui_create("DButton", container)
	buttonInput:Dock(TOP)
	buttonInput:SetTall(40)
	buttonInput:SetText("")

	buttonInput.master = container.master
	buttonInput.disText = text or nil
	buttonInput.callback = callback
	buttonInput.isHovered = false

	function buttonInput:HasHovered(state)
		-- Play sound

		if self.OnHover then
			self.OnHover(state)
		end
	end

	function buttonInput.Paint(self, w, h)
		if self:IsHovered() and not self.isHovered then
			self.isHovered = true
			self:HasHovered(self.isHovered)
		elseif (not self:IsHovered()) and self.isHovered then
			self.isHovered = false
			self:HasHovered(self.isHovered)
		end
		local clr = self:IsHovered() and purple or transWhite
		-- Back Plate
		surface.SetDrawColor(transBlack)
		draw.NoTexture()
		surface.DrawPoly({
			{x = 0, y = 0},
			{x = w, y = 0},
			{x = w - (h*0.5), y = h},
			{x = 0, y = h},
		})
		-- Top Bar
		surface.SetDrawColor(clr)
		surface.DrawPoly({
			{x = 0, y = 0},
			{x = w, y = 0},
			{x = w-7.5, y = 5},--
			{x = 0, y = 5},
		})
		-- Bottom Bar
		surface.DrawPoly({
			{x = 0, y = h-5},
			{x = w - (h*0.5) - 2.5, y = h-5},
			{x = w - (h*0.5), y = h},
			{x = 0, y = h},
		})
		-- Left Bar
		draw.RoundedBox(0, 0, 5, 5, h-10, clr)
		-- Right Bar
		surface.DrawPoly({
			{x = w-7.5, y = 5},
			{x = w, 0},
			{x = w - (h*0.5), y = h},
			{x = w - (h*0.5) - 2.5, y = h-5},
		})

		UILib.DrawScaleText(self.disText or "Button", 20, 15, h/2, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	function buttonInput:DoClick()
		self.callback(buttonInput)
	end

	return buttonInput
end


function UILib.ButtonBox(...)
	local btn = UILib.Button(...)

	function btn:Paint(w, h)
		if self:IsHovered() and not self.isHovered then
			self.isHovered = true
			self:HasHovered(self.isHovered)
		elseif (not self:IsHovered()) and self.isHovered then
			self.isHovered = false
			self:HasHovered(self.isHovered)
		end
		local clr = self:IsHovered() and purple or transWhite
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

		-- Text
		UILib.DrawText(self.disText or "Button", 40, w*0.5, h*0.5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	return btn
end


function UILib.Slider(container, startVal, endVal)
	local shell = vgui.Create("DPanel", container)
	shell:SetPos(0, 0)
	shell:DockMargin(15, 0, 15, 0)
	shell:Dock(TOP)
	shell.Paint = nil

	local slider = vgui.Create("DSlider", shell)
	slider:Dock(FILL)
	slider.startVal = startVal
	slider.endVal = endVal
	slider.value = 0


	function slider:Think()
		local width = self:GetWide()
		local slidePos = self:GetSlideX()
		local segments = endVal - startVal
		local segmentSize = width/segments

		local newVal = startVal + math.Round((width*slidePos)/segmentSize)

		if (not (self.value == newVal)) and shell.OnChange then
			shell:OnChange(newVal)
		end
		self.value = newVal
	end

	function slider:Paint(w, h)
		draw.RoundedBox(0, 0, (h*0.5) - 5, w, 10, white)
		draw.RoundedBox(0, 0, 0, 5, h, white)
		draw.RoundedBox(0, w-5, 0, 5, h, white)
	end

	function slider:PerformLayout()
		local w, h = self:GetSize()

		self.Knob:SetTall(slider:GetTall())
		self.Knob:SetPos((self.m_fSlideX || 0) * w - self.Knob:GetWide() * 0.5, 0)
	end

	local pin = slider.Knob
	slider:SetSlideX(0)
	pin:SetSize(10, slider:GetTall())

	function pin:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, purple)
	end

	function shell:GetValue()
		return slider.value
	end

	local text = UILib.TextPanel(shell, shell:GetValue(), 30, TEXT_ALIGN_LEFT)
	text:Dock(LEFT)
	function text:Think()
		self.text = shell:GetValue()
	end

	return shell
end