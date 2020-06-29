	AddCSLuaFile()

if( CLIENT ) then
    SWEP.PrintName = "Cloaking device";
    SWEP.Slot = 3;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Hold it to become nearly invisible.\n\nDoesn't hide your name, shadow or\nbloodstains on your body."
   };

end

SWEP.Author = "Lykrast"

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

function SWEP:PrimaryAttack()
   return false
end

function SWEP:DrawWorldModel() -- Thanks v_hana :)
	-- if not IsValid(self.Owner) then -- Well let's test this way then
	-- 	self:DrawWorldModel()
	-- end
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Cloak()
    sound.Add({
        name = "vanish",
        channel = CHAN_AUTO,
        volume = 1.0,
        level = 80,
        pitch = {95, 110},
        sound = "npc/stalker/breathing3.wav"
    })

    self.Owner:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.Owner:SetColor( Color(255, 255, 255, 0) )
    self.Owner:SetMaterial( "models/glass" )
    self.SavedWalkSpeed = self.Owner:GetWalkSpeed()
    self.SavedRunSpeed = self.Owner:GetRunSpeed()
    self.Owner:SetWalkSpeed(280)
    self.Owner:SetRunSpeed(200 * 0.3)
    self.Owner:DrawShadow(false)
    self:EmitSound("Vanish", 100)
    self.conceal = true
end

function SWEP:UnCloak()
    self.Owner:SetWalkSpeed(self.SavedWalkSpeed)
    self.Owner:SetRunSpeed(self.SavedRunSpeed)
    self.Owner:DrawShadow(true)
    self.Owner:SetMaterial("")
	self.Owner:SetColor( Color(255, 255, 255) )
    self.conceal = false
end

function SWEP:Deploy()
   self:Cloak()
   return true
end

function SWEP:Holster()
	if ( self.conceal ) then
		self:UnCloak()
	end
	return true
end
 
function SWEP:PreDrop()
	if ( self.conceal ) then
		self:UnCloak()
	end
end

function SWEP:OnDrop() --Hopefully this'll work
	self.Owner:SetColor( Color(255, 255, 255) )
	self:Remove()
end

function SWEP:OnRemove() --Hopefully this'll work
	self.Owner:SetColor( Color(255, 255, 255) )
end