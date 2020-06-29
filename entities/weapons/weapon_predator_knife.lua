AddCSLuaFile()

SWEP.HoldType               = "knife"

if CLIENT then
   SWEP.PrintName           = "Knife"
   SWEP.Slot                = 4

   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 54
   SWEP.DrawCrosshair       = false
   
   SWEP.Icon            = "vgui/ttt/icon_nades"
   SWEP.IconLetter      = "P"
   
end

SWEP.Base                   = "weapon_predatorbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage         = 40
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 2.1
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 10

SWEP.WeaponID               = AMMO_KNIFE

SWEP.IsSilent               = true

-- Pull out faster than standard guns
SWEP.DeploySpeed            = 10

function SWEP:PrimaryAttack()
   sound.Add( {
      name = "Scream",
      channel = CHAN_WEAPON,
      volume = 200.0,
      level = 80,
      pitch = {95, 110},
      sound = "npc/stalker/go_alert2.wav"
  } )
  -- self:EmitSound( "BaseExplosionEffect.Sound", 300 )
  self:EmitSound("Scream", 1)

   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   -- self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

   if not IsValid(self:GetOwner()) then return end

   self:GetOwner():LagCompensation(true)

   local spos = self:GetOwner():GetShootPos()
   local sdest = spos + (self:GetOwner():GetAimVector() * 70)

   local kmins = Vector(1,1,1) * -10
   local kmaxs = Vector(1,1,1) * 10

   local tr = util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

   -- Hull might hit environment stuff that line does not hit
   if not IsValid(tr.Entity) then
      tr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
   end

   local hitEnt = tr.Entity

   -- effects
   if IsValid(hitEnt) then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      local edata = EffectData()
      edata:SetStart(spos)
      edata:SetOrigin(tr.HitPos)
      edata:SetNormal(tr.Normal)
      edata:SetEntity(hitEnt)

      if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
         util.Effect("BloodImpact", edata)
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end

   if SERVER then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end


   if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
      if hitEnt:IsPlayer() then
         -- knife damage is never karma'd, so don't need to take that into
         -- account we do want to avoid rounding error strangeness caused by
         -- other damage scaling, causing a death when we don't expect one, so
         -- when the target's health is close to kill-point we just kill
         if hitEnt:Health() < (self.Primary.Damage + 10) then
            self:StabKill(tr, spos, sdest)
         else
            local dmg = DamageInfo()
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self.Weapon or self)
            dmg:SetDamageForce(self:GetOwner():GetAimVector() * 5)
            dmg:SetDamagePosition(self:GetOwner():GetPos())
            dmg:SetDamageType(DMG_SLASH)

            hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
         end
      end
   end

   self:GetOwner():LagCompensation(false)
end

function SWEP:SecondaryAttack()
   pos = self:GetOwner():GetPos()
   if (SERVER) then
      MakeHurtArea(pos, 250, 5, DMG_BURN, 1, 180)
       for i, ply in ipairs(player.GetAll()) do
           -- PrintMessage(HUD_PRINTTALK, ply:Nick())
           net.Start("Predator_Smoke")
           net.WriteInt(pos.x, 32)
           net.WriteInt(pos.y, 32)
           net.WriteInt(pos.z, 32)
           if (ply:Team() == TEAM_MONSTER) then
               net.WriteInt(20, 32)
           else
               net.WriteInt(80, 32)
           end
           net.Send(ply)
       end
   end
   self:SetNextSecondaryFire(CurTime() + 40)
end

function SWEP:StabKill(tr, spos, sdest)
   local target = tr.Entity

   local dmg = DamageInfo()
   dmg:SetDamage(2000)
   dmg:SetAttacker(self:GetOwner())
   dmg:SetInflictor(self.Weapon or self)
   dmg:SetDamageForce(self:GetOwner():GetAimVector())
   dmg:SetDamagePosition(self:GetOwner():GetPos())
   dmg:SetDamageType(DMG_SLASH)

   -- now that we use a hull trace, our hitpos is guaranteed to be
   -- terrible, so try to make something of it with a separate trace and
   -- hope our effect_fn trace has more luck

   -- first a straight up line trace to see if we aimed nicely
   local retr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})

   -- if that fails, just trace to worldcenter so we have SOMETHING
   if retr.Entity != target then
      local center = target:LocalToWorld(target:OBBCenter())
      retr = util.TraceLine({start=spos, endpos=center, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
   end


   -- create knife effect creation fn
   local bone = retr.PhysicsBone
   local pos = retr.HitPos
   local norm = tr.Normal
   local ang = Angle(-28,0,0) + norm:Angle()
   ang:RotateAroundAxis(ang:Right(), -90)
   pos = pos - (ang:Forward() * 7)

   local prints = self.fingerprints
   local ignore = self:GetOwner()

   target.effect_fn = function(rag)
                         -- we might find a better location
                         local rtr = util.TraceLine({start=pos, endpos=pos + norm * 40, filter=ignore, mask=MASK_SHOT_HULL})

                         if IsValid(rtr.Entity) and rtr.Entity == rag then
                            bone = rtr.PhysicsBone
                            pos = rtr.HitPos
                            ang = Angle(-28,0,0) + rtr.Normal:Angle()
                            ang:RotateAroundAxis(ang:Right(), -90)
                            pos = pos - (ang:Forward() * 10)

                         end

                         local knife = ents.Create("prop_physics")
                         knife:SetModel("models/weapons/w_knife_t.mdl")
                         knife:SetPos(pos)
                         knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                         knife:SetAngles(ang)
                         knife.CanPickup = false

                         knife:Spawn()

                         local phys = knife:GetPhysicsObject()
                         if IsValid(phys) then
                            phys:EnableCollisions(false)
                         end

                         constraint.Weld(rag, knife, bone, 0, 0, true)

                         -- need to close over knife in order to keep a valid ref to it
                         rag:CallOnRemove("ttt_knife_cleanup", function() SafeRemoveEntity(knife) end)
                      end


   -- seems the spos and sdest are purely for effects/forces?
   target:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
end

function SWEP:Equip()
   -- self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   -- self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   function SWEP:DrawHUD()
      local tr = self:GetOwner():GetEyeTrace(MASK_SHOT)
      local x = ScrW() / 2.0
      local y = ScrH() / 2.0

      if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
         if tr.Entity:Health() < (self.Primary.Damage + 10) then
            surface.SetDrawColor(255, 255, 0, 255)
         else
            surface.SetDrawColor(255, 0, 0, 255)
         end
         local outer = 20
         local inner = 10
         surface.DrawLine(x - outer, y - outer, x - inner, y - inner)
         surface.DrawLine(x + outer, y + outer, x + inner, y + inner)
   
         surface.DrawLine(x - outer, y + outer, x - inner, y + inner)
         surface.DrawLine(x + outer, y - outer, x + inner, y - inner)
      end
      
      local txt = "READY"
      if self:GetNextSecondaryFire() - CurTime() > 0 then
         txt = math.floor((self:GetNextSecondaryFire() - CurTime())*10)/10
      end
      draw.SimpleText(txt, "TabLarge", x, y - 30, COLOR_GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
      
      return self.BaseClass.DrawHUD(self)
   end
end


