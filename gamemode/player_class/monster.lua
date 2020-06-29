AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {} 

PLAYER.DisplayName          = "Monster"
PLAYER.WalkSpeed            = 160
PLAYER.RunSpeed             = PLAYER.WalkSpeed * 0.3
PLAYER.TeammateNoCollide    = true

function PLAYER:Spawn()
    BaseClass.Spawn(self)
    self.Player:SetMaxHealth(40 * #player.GetAll())
    self.Player:SetHealth(40 * #player.GetAll())
    self.Player:SetJumpPower(300)
    self.Player:DrawShadow(false)
end

function PLAYER:SetModelForClass()
    self.Player:SetModel("models/player/corpse1.mdl")
end

function PLAYER:Loadout()
    BaseClass.Loadout(self)

    self.Player:RemoveAllItems()
    self.Player:Give("weapon_predator_knife")
    self.Player:Give("weapon_predator_cloak")
    self.Player:Give("weapon_predator_posswitcher")
    self.Player:Give("weapon_predator_crowbar")
    self.Player:AllowFlashlight(false)
    timer.Create("RadarStart", 10, 10, function() RunConsoleCommand("predator_radar_scan") end)
    RunConsoleCommand("predator_radar_scan")
end

player_manager.RegisterClass("monster", PLAYER, "player_default")