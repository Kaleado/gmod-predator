include("player_class/human_shotgun.lua")
include("player_class/human_mac10.lua")
include("player_class/human_incendiary.lua")
include("player_class/human_flashlight.lua")
include("player_class/monster.lua")
include("util.lua")

local snd = sound

GM.Name 	= "Predator"
GM.Author 	= "Kaleado"
GM.Email 	= "N/A"
GM.Website 	= "N/A"

TEAM_HUMAN      = 1
TEAM_MONSTER    = 2
TEAM_SPECTATOR  = 3

team.SetUp(TEAM_HUMAN, "Humans", Color(0, 0, 255))
team.SetUp(TEAM_MONSTER, "Monsters", Color(255, 0, 0))
team.SetUp(TEAM_SPECTATOR, "Spectating", Color(128, 128, 128))

function GM:Initialize()
	-- Do stuff
end

hook.Add( "PlayerFootstep", "CustomFootstep", function( player, pos, foot, sound, volume, rf )
	if player:Team() == TEAM_MONSTER then
		snd.Add( {
			name = "Step",
			channel = CHAN_BODY,
			volume = volume * 30,
			level = 80,
			sound = "npc/zombie/foot2.wav"
		} )
		player:EmitSound( "Step" ) -- Play the footsteps hunter is using
		return true -- Don't allow default footsteps, or other addon footsteps
	end
	return false
end )