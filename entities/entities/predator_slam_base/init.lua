AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

util.AddNetworkString("TTT_SLAMWarning")

include('shared.lua')

hook.Add("TTTPrepareRound", "SLAMClean", function()
	for _, slam in pairs(ents.FindByClass("ttt_slam_*")) do
		slam:Remove()
	end
end)

function ENT:SendWarn(armed)
end

function ENT:Disarm(ply)
	local owner = self:GetPlacer()
	SCORE:HandleC4Disarm(ply, owner, true)

	if (IsValid(owner)) then
		LANG.Msg(owner, "slam_disarmed")
	end

	self:SetBodygroup(0, 0)
	self:SetDefusable(false)
	self:SendWarn(false)
end

function ENT:OnRemove()
	self:SendWarn(false)
end
