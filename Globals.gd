extends Node

var OWNED = true 
var ONLINE = false
var STEAM_ID = 480
var STEAM_NAME = ""

var DATA
var LOBBY_ID = 0
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false

func _ready():
	var INIT = Steam.steamInit(STEAM_ID)
	print("Initialise Steam: ", INIT)
	if INIT == false:
		print("Failed to initialise Steam, shutting down...")
		get_tree().quit()
		return
		
	
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	OWNED = Steam.isSubscribed()
	
	print("Steam is initialise")

func _process(delta):
	Steam.run_callbacks()
