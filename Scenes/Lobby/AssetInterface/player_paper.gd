extends Control
class_name player_paper

@onready var player_profile: TextureRect = $Player_Profile/Control/Player_Profile
@onready var player_name_txt: AutoSizeLabel = $Player_Profile2/Control/player_name

var pending_texture : Texture2D
var pending_name : String

# Setup function
func Player_Paper(new_profile: Texture2D, new_name: String):
	pending_texture = new_profile
	pending_name = new_name

	if is_node_ready():
		apply_data()

func _ready():
	# Make texture stretch correctly
	if player_profile:
		player_profile.stretch_mode = TextureRect.STRETCH_SCALE
		player_profile.expand = true

	apply_data()

func apply_data():
	if player_profile:
		player_profile.texture = pending_texture
	if player_name_txt:
		player_name_txt.text = pending_name
