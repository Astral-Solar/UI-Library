util.AddNetworkString("Astral:UILib:ChangeLook")

UILib.Core.Bodygroups = UILib.Core.Bodygroups or {}
net.Receive("Astral:UILib:ChangeLook", function(_, ply)
	if AstralLib.RateLimit.Check("Astral:UILib:ChangeLook", 5, ply) then return end

	local jobCommand = net.ReadString()
	local modelID = net.ReadUInt(6)
	local skinID = net.ReadUInt(6)
	local bodyGroupCount = net.ReadUInt(6)
	local bodyGroups = {}
	for i=1, bodyGroupCount do
		bodyGroups[net.ReadUInt(6)] = net.ReadUInt(6)
	end

	UILib.Core.Bodygroups[ply:SteamID64()] = UILib.Core.Bodygroups[ply:SteamID64()] or {}

	UILib.Core.Bodygroups[ply:SteamID64()][jobCommand] = {
		model = modelID or 1,
		skin = skinID or 0,
		bodygroups = bodyGroups or {}
	}
end)

hook.Add("PlayerLoadout", "Astral:UILib:Look", function(ply)
	if not UILib.Core.Bodygroups[ply:SteamID64()] then return end

	local plyJob = RPExtraTeams[ply:Team()]
	local customData = UILib.Core.Bodygroups[ply:SteamID64()][plyJob.command]
	
	if not customData then return end

	-- Set the model
	if istable(plyJob.model) then
		local model = plyJob.model[customData.modelID]
		if model then
			ply:SetModel(model)
		end
	end
	-- Set the skin
	ply:SetSkin(customData.skin)
	-- Set the bodygroups
	for k, v in pairs(customData.bodygroups) do
		ply:SetBodygroup(k, v)
	end
end)