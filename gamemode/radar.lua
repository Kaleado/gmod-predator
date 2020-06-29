-- Traitor radar functionality

-- should mirror client
local chargetime = 5

local math = math

print("radar.lua")

local function RadarScan(ply, cmd, args)
   if ply:Team() == TEAM_MONSTER or ply:Team() == TEAM_SPECTATOR then

        ply.radar_charge =  CurTime() + chargetime

        -- if ply.radar_charge > CurTime() then
        --    -- LANG.Msg(ply, "radar_charging")
        --    return
        -- end

        local scan_ents = player.GetAll()

        local targets = {}
        for k, p in pairs(scan_ents) do
        if ply == p or (p:Team() == TEAM_SPECTATOR) then continue end

        local pos = p:LocalToWorld(p:OBBCenter())

        -- Round off, easier to send and inaccuracy does not matter
        pos.x = math.Round(pos.x)
        pos.y = math.Round(pos.y)
        pos.z = math.Round(pos.z)

        local role = TEAM_HUMAN

        table.insert(targets, {role=role, pos=pos})
        end

        net.Start("TTT_Radar")
        net.WriteUInt(#targets, 8)
        for k, tgt in pairs(targets) do
            net.WriteUInt(tgt.role, 2)

            net.WriteInt(tgt.pos.x, 32)
            net.WriteInt(tgt.pos.y, 32)
            net.WriteInt(tgt.pos.z, 32)
        end
        net.Send(ply)
   end
end

concommand.Add("predator_radar_scan", RadarScan)

