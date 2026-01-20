extends Node2D

var appID = "480"

func _init() -> void:
	OS.set_environment("SteamAppID", appID)
	OS.set_environment("SteamGameID", appID)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.steamInit()
	var steamRunning = Steam.isSteamRunning()
	
	if !steamRunning:
		print("Error: Steam not running")
		return
	
	print("Steam is running")
	var id = Steam.getSteamID()
	var playerName = Steam.getFriendPersonaName(id)
	print("Username: ", str(playerName))
