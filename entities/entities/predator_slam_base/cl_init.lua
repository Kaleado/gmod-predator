include('shared.lua')

ENT.PrintName = "M4 SLAM"

net.Receive("TTT_SLAMWarning", function()
	local idx = net.ReadUInt(16)
	local armed = net.ReadBool()

	if armed then
		local pos = net.ReadVector()
		RADAR.bombs[idx] = {pos=pos, nick="SLAM"}
	else
		RADAR.bombs[idx] = nil
	end

	RADAR.bombs_count = table.Count(RADAR.bombs)
end)
