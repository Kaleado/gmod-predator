DeriveGamemode("base")
DEFINE_BASECLASS("gamemode_base")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_radar.lua")

include("shared.lua")
include("radar.lua")

local human_classes = {"human_flashlight", "human_incendiary", "human_mac10", "human_shotgun"}

local math = math

util.AddNetworkString( "TTT_Radar" )
util.AddNetworkString( "Predator_Smoke" )

function GM:PlayerConnect(name, ip)
end

function GM:PlayerDisconnected(player)
end

function GM:PostPlayerDeath(player)
    player:SetTeam(TEAM_SPECTATOR)
    player_manager.ClearPlayerClass(player)
    player:Spectate(OBS_MODE_ROAMING)
    
    monsters = team.GetPlayers(TEAM_MONSTER)
    monsters_dead = true
    for i, v in ipairs(monsters) do
        monsters_dead = monsters_dead and not v:Alive()
    end

    humans = team.GetPlayers(TEAM_HUMAN)
    humans_dead = true
    for i, v in ipairs(humans) do
        humans_dead = humans_dead and not v:Alive()
    end

    if monsters_dead then
        human_wins = human_wins + 1
        PrintMessage(HUD_PRINTCENTER, "Humans win!")
        timer.Create("RestartTimer", 5, 1, RestartRound)
    elseif humans_dead then
        monster_wins = monster_wins + 1
        PrintMessage(HUD_PRINTCENTER, "Monsters win!")
        timer.Create("RestartTimer", 5, 1, RestartRound)
    end
end

function GM:PlayerSpawn(player, transition)
    BaseClass.PlayerSpawn(self, player, transition)
end

function GM:PlayerSetModel(player)
    if player:Team() == TEAM_SPECTATOR then
        player:SetRenderMode(RENDERMODE_TRANSCOLOR)
        player:SetColor(Color(0,0,0,0))
        return
    else
        player:SetRenderMode(RENDERMODE_NORMAL)
        -- player:SetColor(Color(0,0,0,255))
    end

    player_manager.RunClass(player, "SetModelForClass")
end

function GM:PlayerDeathThink(player)
    return false
end

function GM:CanPlayerSuicide(player)
    if (player:Team() == TEAM_SPECTATOR) then
        return false
    end
    return true
end

function GM:PlayerShouldTakeDamage(player, attacker)
    return true
end

-- Custom functions for Predator

function SurvivalWin()
    PrintMessage(HUD_PRINTCENTER, "Humans win!")
    timer.Create("RestartTimer", 5, 1, RestartRound)
end

-- Called to set up a new round
function StartRound()
    all_players = player.GetAll()
    n_players = #all_players
    monster_idx = math.random(1, n_players)
    PrintMessage(HUD_PRINTCENTER, all_players[monster_idx]:Nick() .. " is the monster! They will spawn in 45 seconds...")

    classes = table.Shuffle(human_classes)
    j = 0
    for i, v in ipairs(all_players) do
        if i != monster_idx then
            v:SetTeam(TEAM_HUMAN)
            player_manager.SetPlayerClass(v, classes[1 + j % #classes])
            j = j + 1
            v:Spawn()
        else
            v:RemoveAllItems()
            v:Spectate(OBS_MODE_ROAMING)
            v:SetTeam(TEAM_SPECTATOR)
            player_manager.ClearPlayerClass(v)
            v:SetRenderMode(RENDERMODE_TRANSCOLOR)
            v:SetColor(Color(0,0,0,0))

            timer.Create("MonsterSpawn", 45, 1, function() 
                v:SetTeam(TEAM_MONSTER)
                player_manager.SetPlayerClass(v, "monster")
                v:Spawn() 
                PrintMessage(HUD_PRINTCENTER, "The monster has spawned! Your goal: survive for 3 minutes")
                timer.Create("SurvivalWin1", 120, 1, function() PrintMessage(HUD_PRINTCENTER, "60 seconds remaining") end)
                timer.Create("SurvivalWin2", 150, 1, function() PrintMessage(HUD_PRINTCENTER, "30 seconds remaining") end)
                timer.Create("SurvivalWin3", 170, 1, function() PrintMessage(HUD_PRINTCENTER, "10 seconds remaining") end)
                timer.Create("SurvivalWin4", 180, 1, SurvivalWin)
            end)
        end
    end
end

-- Called when one team is eliminated to clean up etc.
function PostRound()
    all_players = player.GetAll()
    for i, v in ipairs(all_players) do
        v:RemoveAllItems()
        v:SetObserverMode(OBS_MODE_NONE)
    end
    timer.Destroy("SurvivalWin1")
    timer.Destroy("SurvivalWin2")
    timer.Destroy("SurvivalWin3")
    timer.Destroy("SurvivalWin4")
    game.CleanUpMap()
end

function RestartRound()
    PostRound()
    timer.Create("StartRound", 1, 1, StartRound)
end

function ResetStats()
    monster_wins = 0
    human_wins = 0
end

function PrintStats()
    PrintMessage(HUD_PRINTTALK, "Monster wins: " .. monster_wins)
    PrintMessage(HUD_PRINTTALK, "Human wins: " .. human_wins)
end

concommand.Add("predator_restart_round", RestartRound)

concommand.Add("predator_stats", PrintStats)
concommand.Add("predator_reset_stats", ResetStats)