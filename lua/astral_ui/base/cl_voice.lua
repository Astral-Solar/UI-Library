UILib.Voice = UILib.Voice or {}
local ply = FindMetaTable("Player")

function UILib.Voice.Start(ply)
	UILib.Voice[ply:SteamID64()] = true
end
function UILib.Voice.Stop(ply)
	UILib.Voice[ply:SteamID64()] = nil
end