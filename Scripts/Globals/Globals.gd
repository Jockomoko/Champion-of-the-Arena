extends Node

# Steam
var STEAM_NAME: String = ""
var STEAM_ID: int = 0
const APP_ID: int = 480

# Lobby
var LOBBY_ID: int = 0

var MY_PLAYERCONTROLLER : PlayerController

var LOBBY_INVITE_ARG: bool = false

#saved champions path
const SAVED_CHAMPION_PATH = "user://champion_stats.json"

func _ready():
	var INIT = Steam.steamInit(APP_ID)
	print("Initialise Steam: ", INIT)
	if INIT == false:
		print("Failed to initialise Steam, shutting down...")
		get_tree().quit()
		return
		
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	
	print("Steam is initialise")
	print("Steam_ID ", STEAM_ID)
	print("Steam_Name", STEAM_NAME)
func _process(delta):
	Steam.run_callbacks()
