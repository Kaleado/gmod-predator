AddCSLuaFile()

if( CLIENT ) then
    SWEP.PrintName = "Smoke breath";
    SWEP.Slot = 3;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Fire to create smoke around you"
   };

end

SWEP.Author = "Kaleado"

SWEP.Base = "weapon_predatorbase"
SWEP.Spawnable= false
SWEP.AdminSpawnable= true
SWEP.HoldType = "slam"
 
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
 
SWEP.ViewModelFOV   = 60
SWEP.ViewModelFlip  = false
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel     = "models/weapons/w_slam.mdl"
SWEP.UseHands	    = true
 
 --- PRIMARY FIRE ---
SWEP.Primary.Delay          = 0.5
SWEP.Primary.Recoil         = 0
SWEP.Primary.Damage         = 0
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.NoSights               = true
SWEP.AllowDrop              = false
SWEP.DeploySpeed            = 1000

AccessorFunc( SWEP, "radius", "Radius", FORCE_NUMBER )

if CLIENT then

    local smokeparticles = {
       Model("particle/particle_smokegrenade"),
       Model("particle/particle_noisesphere")
    };
 
    function SWEP:CreateSmoke(center)
       local em = ParticleEmitter(center)
 
       local r = self:GetRadius()
       for i=1, 150 do
          local prpos = VectorRand() * r
          prpos.z = prpos.z + 32
          local p = em:Add(table.Random(smokeparticles), center + prpos)
          if p then
             local gray = math.random(75, 200)
             p:SetColor(gray, gray, gray)
             p:SetStartAlpha(255)
             p:SetEndAlpha(200)
             p:SetVelocity(VectorRand() * math.Rand(900, 1300))
             p:SetLifeTime(0)
             
             p:SetDieTime(math.Rand(50, 70))
 
             p:SetStartSize(math.random(80, 90))
             p:SetEndSize(math.random(1, 40))
             p:SetRoll(math.random(-180, 180))
             p:SetRollDelta(math.Rand(-0.1, 0.1))
             p:SetAirResistance(600)
 
             p:SetCollide(true)
             p:SetBounce(0.4)
 
             p:SetLighting(false)
          end
       end
 
       em:Finish()
    end
end

 function SWEP:Initialize()
    if not self:GetRadius() then self:SetRadius(150) end

    self.BaseClass.Initialize(self)
    self:SetDeploySpeed(50)
 end

function SWEP:PrimaryAttack()
    pos = self:GetOwner():GetPos()
    if (SERVER) then
        for i, ply in ipairs(player.GetAll()) do
            PrintMessage(HUD_PRINTTALK, ply:Nick())
            net.Start("Predator_Smoke")
            net.WriteInt(pos.x, 32)
            net.WriteInt(pos.y, 32)
            net.WriteInt(pos.z, 32)
            if (ply:Team() == TEAM_MONSTER) then
                net.WriteInt(20, 32)
            else
                net.WriteInt(255, 32)
            end
            net.Send(ply)
        end
    end
    self:SetNextPrimaryFire(CurTime() + 10)
end

function SWEP:DrawWorldModel() -- Thanks v_hana :)
	-- if not IsValid(self.Owner) then -- Well let's test this way then
	-- 	self:DrawWorldModel()
	-- end
end

function SWEP:DrawWorldModelTranslucent()
end

-- function SWEP:Cloak()
--     sound.Add({
--         name = "vanish",
--         channel = CHAN_AUTO,
--         volume = 1.0,
--         level = 80,
--         pitch = {95, 110},
--         sound = "npc/stalker/breathing3.wav"
--     })

--     self.Owner:SetRenderMode(RENDERMODE_TRANSCOLOR)
--     self.Owner:SetColor( Color(255, 255, 255, 0) )
--     self.Owner:SetMaterial( "models/glass" )
--     self.SavedWalkSpeed = self.Owner:GetWalkSpeed()
--     self.SavedRunSpeed = self.Owner:GetRunSpeed()
--     self.Owner:SetWalkSpeed(220)
--     self.Owner:SetRunSpeed(200 * 0.3)
--     self:EmitSound("Vanish", 100)
--     self.conceal = true
-- end

function SWEP:Deploy()
   -- self:Cloak()
   return true
end

function SWEP:Holster()
	-- if ( self.conceal ) then
	-- 	self:UnCloak()
	-- end
	return true
end
 
function SWEP:PreDrop()
	-- if ( self.conceal ) then
	-- 	self:UnCloak()
	-- end
end

function SWEP:OnDrop() --Hopefully this'll work
	-- self.Owner:SetColor( Color(255, 255, 255) )
	-- self:Remove()
end

function SWEP:OnRemove() --Hopefully this'll work
	-- self.Owner:SetColor( Color(255, 255, 255) )
end