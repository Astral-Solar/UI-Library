-- This is the code that actually disables the drawing.
local hideHUDElements = {
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_EntityDisplay"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudAmmo"] = true,
	["CHudBattery"] = true,
	["CHudHealth"] = true,
	["DarkRP_LockdownHUD"] = true
	--["DarkRP_HUD"] = true
}
hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name) if hideHUDElements[name] then return false end end)
hook.Add("HUDDrawTargetID", "HMHUD", function() return end)
hook.Remove("HUDPaint", "DarkRP_Mod_HUDPaint")

-- Cache
local scrw = ScrW
local scrh = ScrH
local localplayer = LocalPlayer
local color = Color
local draw_box = draw.RoundedBox
local getglobalbool = GetGlobalBool
local math_clamp = math.Clamp
local player_getall = player.GetAll

-- Colors
local white = color(255, 255, 255)
local grey = color(220, 220, 220)
local red = color(220, 0, 0)

-- We have to start the number in a weird way because EyeAngle returns -180 to 180
local compassPoints = {
	[180] = "N",
	[225] = "NE",
	[270] = "E",
	[315] = "SE",
	[360] = "S",
	[0] = "S", -- We do the same value twice because I cba to do brain hurty math
	[45] = "SW",
	[90] = "W",
	[135] = "NW",
}
function UILib.HUD()
	-- Cache values to optimize
	local _scrw, _scrh = scrw(), scrh()
	local localPly = localplayer()

	-- Health
	UILib.DrawScaleText(localPly:Health(), 23, _scrw * 0.05, _scrh - 60, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "orbitron")
	UILib.DrawScaleText("Health", 10, _scrw * 0.05, _scrh - 68, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, "orbitron")
	-- Armour
	UILib.DrawScaleText(localPly:Armor(), 23, _scrw * 0.15, _scrh - 60, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "orbitron")
	UILib.DrawScaleText("Armor", 10, _scrw * 0.15, _scrh - 68, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, "orbitron")

	-- Ammo
	local activeWep = localPly:GetActiveWeapon()
	if not (activeWep == NULL) then
		local ammoinclip = activeWep:Clip1()
		
		if ammoinclip > -1 then
			UILib.DrawScaleText(ammoinclip.."/"..localPly:GetAmmoCount(activeWep:GetPrimaryAmmoType()), 23, _scrw * 0.9, _scrh - 60, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "orbitron")
			UILib.DrawScaleText("Ammo", 10, _scrw * 0.9, _scrh - 68, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, "orbitron")
		end
	end

	-- Compass
	local plyAng = math.Round(localPly:EyeAngles().yaw)
	local plyPos = localPly:GetPos()
	UILib.DrawScaleText("BEARING "..((-plyAng) + 180).."° | ALTITUDE "..math.Round(plyPos.z*0.01).." | CO-ORDINATES "..math.Round(plyPos.x*0.01).." "..math.Round(plyPos.y*0.01), 9, _scrw * 0.5,_scrh - 70, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, "orbitron")
	-- Compass box
	local compBoxWidth = _scrw * 0.3
	UILib.DrawBox(compBoxWidth, _scrh - 70, _scrw * 0.4, 30)
	-- NESW text
	for i=0, 360 do
		local dif = math.AngleDifference(i, plyAng)
		if math.abs(dif) < 80 then
			local pos = dif/25 * (compBoxWidth/5)

			if not (i % 45 == 0) then continue end
			UILib.DrawScaleText(compassPoints[360 - i], 8, ScrW()/2 - pos, _scrh - 55, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "orbitron")
		end
	end
end
hook.Add("HUDPaint", "Astral:UILib:DrawHUD", UILib.HUD)


function UILib.OverHead()
    local shootPos = LocalPlayer():GetShootPos()
    local aimVec = LocalPlayer():GetAimVector()

    for _, ply in ipairs(player_getall()) do
        if (not IsValid(ply)) or (ply == LocalPlayer()) or (not ply:Alive()) or ply:GetNoDraw() or ply:IsDormant() then continue end
        local hisPos = ply:GetShootPos()

        -- Draw when you're (almost) looking at him
    	if hisPos:DistToSqr(shootPos) < 160000 then
            local pos = hisPos - shootPos
            local unitPos = pos:GetNormalized()
            if unitPos:Dot( aimVec ) > 0.95 then
                local trace = util.QuickTrace( shootPos, pos, LocalPlayer() )
                if trace.Hit and trace.Entity ~= ply then break end

                local pos = ply:EyePos()
				pos.z = pos.z + 8 --The position we want is a bit above the position of the eyes
				pos = pos:ToScreen()
				pos.y = pos.y - 85

				local plyName = (ply:Name() or "Unknown")
				local plyJob = (ply:getDarkRPVar("job") or "Unknown")

				-- Text
				UILib.DrawText(UILib.CharLimit(plyName, 30), 30, pos.x, pos.y+20, team.GetColor(ply:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "orbitron")
				UILib.DrawText(plyJob, 25, pos.x, pos.y+45, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "orbitron")
				UILib.DrawText("HP: "..ply:Health().." | AR: "..ply:Armor(), 20, pos.x, pos.y+65, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "orbitron")

				if ply:IsMuted() then
					UILib.DrawText("Muted", 35, pos.x, pos.y-10, red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "orbitron")
				end
            end
        end
    end

    local tr = LocalPlayer():GetEyeTrace()

    if IsValid( tr.Entity ) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():DistToSqr( LocalPlayer():GetPos() ) < 40000 then
        tr.Entity:drawOwnableInfo()
    end
end
hook.Add("HUDPaint", "Astral:UILib:DrawOverHead", UILib.OverHead)