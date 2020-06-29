AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName          = "Human"
PLAYER.WalkSpeed            = 180
PLAYER.RunSpeed             = PLAYER.WalkSpeed * 0.3
PLAYER.TeammateNoCollide    = false

function PLAYER:Spawn()
    BaseClass.Spawn(self)
    self.Player:SetHealth(75)
    self.Player:SetMaxHealth(75)
end

function PLAYER:SetModelForClass()
    self.Player:SetModel("models/player/Group02/male_02.mdl")
end

function PLAYER:Loadout()
    BaseClass.Loadout(self)

    self.Player:RemoveAllItems()
    self.Player:GiveAmmo(60, "PISTOL", true)
    self.Player:GiveAmmo(3, "MOLOTOV", true)
    self.Player:Give("weapon_predator_molotov")
    self.Player:Give("weapon_predator_pistol")
    self.Player:Give("weapon_predator_crowbar")
    self.Player:AllowFlashlight(false)
end

player_manager.RegisterClass("human_incendiary", PLAYER, "player_default")