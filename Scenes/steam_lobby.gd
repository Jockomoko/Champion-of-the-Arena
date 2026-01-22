extends Node2D

#For more info watch https://www.youtube.com/watch?v=si50G3S1XGU

enum lobby_status {Private, Friends, Public, Invisible}
enum search_disctance {Close, Default, Far, Worlwide}

var max_player_amount = 6

@onready var steam_name: Label = $MarginContainer2/VBoxContainer/TopHBOX/MarginContainer2/VBoxContainer/SteamName
@onready var lobby_name_text_box: TextEdit = $MarginContainer2/VBoxContainer/TopHBOX/MarginContainer/VBoxContainer/LobbyNameTextBox
@onready var label: Label = $MarginContainer2/VBoxContainer/MarginContainer/Panel/VBoxContainer2/Label
@onready var start: Button = $MarginContainer2/VBoxContainer/TopHBOX/MarginContainer2/VBoxContainer/StartMargin/Start
@onready var create: Button = $"Left side/VBoxContainer/CreateMargin/Create"
@onready var join: Button = $"Left side/VBoxContainer/JoinMargin/Join"
@onready var leave: Button = $"Left side/VBoxContainer/LeaveMargin/Leave"
@onready var chat_box: RichTextLabel = $MarginContainer2/VBoxContainer/MarginContainer/Panel/VBoxContainer2/RichTextLabel
@onready var player_in_lobby: RichTextLabel = $"Left side/VBoxContainer/PlayersMargin/Panel/VBoxContainer2/RichTextLabel"

func _ready():
	# Set steam name on screen
	steam_name.text = Globals.STEAM_NAME
	
	# Steam connections
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.join_requested.connect(_on_lobby_join_requested)

	check_command_line()


func create_lobby():
	if Globals.LOBBY_ID == 0:
		Steam.createLobby(lobby_status.Public, max_player_amount)

func join_lobby(lobbyID):
	Steam.getLobbyData(lobbyID, "name")
	Globals.LOBBY_MEMBERS.clear()
	Steam.joinLobby(lobbyID)

func _on_lobby_joined(lobbyID, permissions, locked, response):
	Globals.LOBBY_ID = lobbyID
	Steam.getLobbyData(lobbyID, "name")
	label.text = str(name)
	get_lobby_members()
	
func _on_lobby_join_requested(lobbyID, friendID):
	var owner_name = Steam.getFriendPersonaName(friendID)
	display_message("Joining " + str(owner_name) + " lobby")
	join_lobby(lobbyID)

func _on_lobby_created(connectStatus, lobbyID):
	if connectStatus == 1:
		Globals.LOBBY_ID = lobbyID
		display_message("Created Lobby: " + lobby_name_text_box.text)
		
		#Set lobby data
		Steam.setLobbyData(lobbyID, "name", lobby_name_text_box.text)
		Steam.getLobbyData(lobbyID, "name")
		label.text = str(name)

func _on_lobby_chat_update(lobbyID, changedID, makingChangeID, chatstate):
	var changer = Steam.getFriendPersonaName(makingChangeID)
	
	match chatstate:
		1:
			display_message(str(changer)+" has joined the lobby")
		2:
			display_message(str(changer)+" has left the lobby")
		8:
			display_message(str(changer)+" was kicked form the lobby")
		_:
			display_message(str(changer)+" did something")
	
	get_lobby_members()
	

func _on_lobby_data_update(success, lobbyID, memberID, key):
	print("Success: "+str(success)+", Lobby ID: "+str(lobbyID)+", Member ID: " + str(memberID)+", key: "+str(key))

func display_message(message):
	chat_box.add_text("\n" + str(message))

func check_command_line():
	var ARGUMENTS = OS.get_cmdline_args()
	
	if ARGUMENTS.size() > 0:
		for argument in ARGUMENTS:
			if Globals.LOBBY_INVITE_ARG:
				join_lobby(int(argument))
			
			if argument == "+connect_lobby":
				Globals.LOBBY_INVITE_ARG = true

func get_lobby_members():
	Globals.LOBBY_MEMBERS.clear()
	
	var membercount = Steam.getNumLobbyMembers(Globals.LOBBY_ID)
	
	display_message("Player amount: " + str(membercount))
	
	for member in range(0, membercount):
		var member_steam_id = Steam.getLobbyMemberByIndex(Globals.LOBBY_ID, member)
		var member_steam_name = Steam.getFriendPersonaName(member_steam_id)
		
		add_player_list(member_steam_id, member_steam_name)

func add_player_list(steamID, steamName):
	Globals.LOBBY_MEMBERS.append({"steam_id":steamID, "steam_name": steamName})
	player_in_lobby.clear()
	
	for member in Globals.LOBBY_MEMBERS:
		player_in_lobby.add_text(str(member["steam_name"] + "\n"))
	
func leave_lobby():
	if Globals.LOBBY_ID != 0:
		display_message("Leaving lobby..")
		Steam.leaveLobby(Globals.LOBBY_ID)
		Globals.LOBBY_ID = 0
		lobby_name_text_box.text = "lobby name"
		
		for member in Globals.LOBBY_MEMBERS:
			Steam.closeP2PSessionWithUser(member["steam_id"])
			Globals.LOBBY_MEMBERS.clear()

func _on_start_pressed() -> void:
	pass


func _on_create_pressed() -> void:
	create_lobby()


func _on_join_pressed() -> void:
	Steam.addRequestLobbyListDistanceFilter(search_disctance.Worlwide)
	display_message("Searing for lobbies...")
	
	Steam.requestLobbyList()


func _on_leave_pressed() -> void:
	leave_lobby()
