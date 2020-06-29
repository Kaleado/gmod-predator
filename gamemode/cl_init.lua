include("shared.lua")
include("cl_radar.lua")

print("hello from the client")

function GM:HUDShouldDraw(name)
    if ( name == "CHudHealth" or name == "CHudAmmo" ) then
        return false
    end
    return true
end

function GM:HUDClear()
    RADAR:Clear()
 end

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

function GM:DrawDeathNotice( x, y )
end

function GM:HUDDrawTargetID()
    return false
end

hook.Add( "RenderScreenspaceEffects", "color_modify_example", function()
    if LocalPlayer():Team() != TEAM_SPECTATOR then
        tab["$pp_colour_colour"] = (LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 0.6
        tab["$pp_colour_addr"] = 0.4 - (LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 0.4
        DrawColorModify( tab )
    end
end )

-- Smoke

SMOKE_RADIUS = 250

local smokeparticles = {
    Model("particle/particle_smokegrenade"),
    Model("particle/particle_noisesphere")
 };

 function CreateSmoke(center, transparency)
    local em = ParticleEmitter(center)

    local r = SMOKE_RADIUS -- self:GetRadius()
    for i=1, 1200 do
       local prpos = VectorRand() * r
       prpos.z = prpos.z + 32
       local p = em:Add(table.Random(smokeparticles), center + prpos)
       if p then
          local gray = math.random(0, 75)
          p:SetColor(gray, gray, gray)
          p:SetStartAlpha(transparency)
          p:SetEndAlpha(transparency * (200/255))
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

local function ReceiveSmoke()
    print("receiving smoke")
    local pos = Vector()
    pos.x = net.ReadInt(32)
    pos.y = net.ReadInt(32)
    pos.z = net.ReadInt(32)
    local transparency = net.ReadInt(32)
    CreateSmoke(pos, transparency)
 end

 net.Receive("Predator_Smoke", ReceiveSmoke)