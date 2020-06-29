AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")
ENT.next_hurt = 0
ENT.damage_interval = 0

AccessorFunc(ENT, "dietime", "DieTime")
AccessorFunc(ENT, "damage_amount", "DamageAmount")
AccessorFunc(ENT, "damage_type", "DamageType")
AccessorFunc(ENT, "damage_radius", "DamageRadius")
AccessorFunc(ENT, "damage_interval", "DamageInterval")

-- AccessorFuncDT(ENT, "burning", "Burning")

function MakeHurtArea(pos, radius, damage_amt, damage_type, interval, lifetime)
    local area = ents.Create("predator_hurtarea")
    area:SetPos(pos)
    area:SetDamageAmount(damage_amt)
    area:SetDamageType(damage_type)
    area:SetDamageRadius(radius)
    area:SetDamageInterval(interval)
    area:SetDieTime(CurTime() + lifetime)
    area:Spawn()
    area:PhysWake()
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:DrawShadow(false)
    self:SetNoDraw(true)

    self:PhysicsInit(SOLID_VPHYSICS) -- SOLID_NONE
    self:SetMoveType(MOVETYPE_VPHYSICS) -- MOVETYPE_NONE
    self:SetSolid(SOLID_VPHYSICS) -- SOLID_NONE
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetHealth(99999)

    print(self:GetDamageInterval())

    self.next_hurt = CurTime() + self:GetDamageInterval() + math.Rand(0, 3)
    if self.dietime == 0 then self.dietime = CurTime() + 20 end
end

function RadiusDamage(dmginfo, pos, radius, inflictor)
    local tr = nil
    for k, vic in ipairs(ents.FindInSphere(pos, radius)) do
        if IsValid(vic) and vic:IsPlayer() and vic:Alive() and vic:Team() == TEAM_HUMAN then
            vic:TakeDamageInfo(dmginfo)
        end
    end
 end

function ENT:Think()
    if CLIENT then return end
 
    if self.dietime < CurTime() then
        self:Remove()
        return
    end

    if self.next_hurt < CurTime() then
        -- deal damage
        local dmg = DamageInfo()
        dmg:SetDamageType(self:GetDamageType())
        dmg:SetDamage(self:GetDamageAmount())

        RadiusDamage(dmg, self:GetPos(), self:GetDamageRadius(), self)
        print('hahaha')

        self.next_hurt = CurTime() + self.damage_interval
     end
end