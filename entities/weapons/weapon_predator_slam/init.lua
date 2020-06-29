AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Think()
	self:ChangeAnimation()

	self:NextThink(CurTime() + 0.25)
	return true
end
