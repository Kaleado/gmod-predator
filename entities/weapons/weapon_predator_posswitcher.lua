AddCSLuaFile()

SWEP.Base	=	"weapon_predatorbase"

if CLIENT then

SWEP.PrintName		=	"Position Swapper v2"
SWEP.Slot			=	2
SWEP.Icon 			=	"VGUI/ttt/icon_posswitch"
SWEP.DrawAmmo		=	false
SWEP.DrawCrosshair	=	false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.ViewModelFlip       = false
SWEP.ViewModelFOV        = 54

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Right-click to select a target, left-click to make a swap and reload to deselect your target!"
   };

end

SWEP.Spawnable		=	true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

SWEP.Kind                   = WEAPON_EQUIP2
SWEP.CanBuy                 = {ROLE_TRAITOR}
SWEP.LimitedStock           = true
SWEP.WeaponID               = POSITION_SWITCH

if SERVER then

    function SWEP:SecondaryAttack()
        local owner = self.Owner
        local target = self.Owner:GetEyeTrace().Entity
        if target:IsPlayer() && target:Alive() then
            owner:ChatPrint( "You've selected " .. target:Nick() .. "" )
            target:ChatPrint( "You've been targeted by someone's position switcher!" )
            return self:SetTargetEnt( target )
        elseif
            ( target:IsPlayer() && !target:Alive() ) || ( !target:IsPlayer() ) then
            owner:ChatPrint( "No target was found!" )
            return "failed"
        end
    end

    function SWEP:SetTargetEnt( ent )
        self.TargetEnt = ent
    end


    function SWEP:GetTargetEnt()
        return self.TargetEnt
    end


    function SWEP:PrimaryAttack()
        local owner = self.Owner
        local target = self.TargetEnt
        if IsValid( target ) then
            -- target:ChatPrint( "You will be teleported in 3 seconds!" )
            --timer.Create( "PositionSwitcherTimer", 3, 1, function()
                if ( target:Alive() ) then
                    local selfpos = owner:GetPos()
                    local entpos = self.TargetEnt:GetPos()
                    owner:SetPos( entpos )
                    target:SetPos( selfpos )
                    owner:ChatPrint( "Swapped position with " .. target:Nick() .. "." )
                    -- self:Remove()
                else
                    owner:ChatPrint( "The target is dead!" )
                end
            --end )
        else
            owner:ChatPrint( "No target is selected: right-click on a player to select one." )
            return "failed"    
        end
        self:SetNextPrimaryFire(CurTime() + 5)
    end


    function SWEP:Reload()
            if 	!self:GetTargetEnt() then
                return "failed"
            else
                self:SetTargetEnt( nil )
                self.Owner:ChatPrint( "Your target has been deselected" )
            end
    end

    function SWEP:PreDrop()
        self:SetTargetEnt(nil)
    end

    function SWEP:OnRemove()
        self:SetTargetEnt(nil)
    end

end
