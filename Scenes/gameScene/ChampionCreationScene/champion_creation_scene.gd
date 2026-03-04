extends Node2D

const CHAMPION_DESIGNE = preload("uid://cde8bhw4fqnqs")
const STATS_COMPONENT  = preload("uid://cuxf7gcv3feum")
const STATS_CHANGER    = preload("uid://ijsge7t485at")

@onready var champion_1Vbox: VBoxContainer = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/ChampionsContainer/MarginContainer/Champion1_stats
@onready var champion_2Vbox: VBoxContainer = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/ChampionsContainer/MarginContainer/Champion2_stats
@onready var stat_point_champion_1_txt: AutoSizeLabel = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/stat_point_champion1_txt
@onready var stat_point_champion_2_txt: AutoSizeLabel = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/stat_point_champion2_txt

var champion_1_design: Control
var champion_2_design: Control
var color_picker: ColorPicker

const path := Globals.SAVED_CHAMPION_PATH

var NewTeamComponent = TeamComponent.new()
var appearance_1 := AppearanceComponent.new()
var appearance_2 := AppearanceComponent.new()

var stats_point_champion1 = NewTeamComponent.stats_points
var stats_point_champion2 = NewTeamComponent.stats_points
var min_stat_point = 5

var hair_index_1 := 0
var eye_index_1 := 0
var mouth_index_1 := 0
var hair_index_2 := 0
var eye_index_2 := 0
var mouth_index_2 := 0

func _ready() -> void:
	# Spawn champion designs dynamically
	champion_1_design = CHAMPION_DESIGNE.instantiate()
	$Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/ChampionsContainer.add_child(champion_1_design)
	# Move to first index in VBoxContainer
	$Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/ChampionsContainer.move_child(champion_1_design, 0)

	champion_2_design = CHAMPION_DESIGNE.instantiate()
	$Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/ChampionsContainer.add_child(champion_2_design)
	# Move to first index in VBoxContainer
	$Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/ChampionsContainer.move_child(champion_2_design, 0)

	# Connect signals for Champion 1
	champion_1_design.go_left_hair_index.connect(func(): _change_index("hair", -1, 1))
	champion_1_design.go_Right_hair_index.connect(func(): _change_index("hair", 1, 1))
	champion_1_design.go_left_eye_index.connect(func(): _change_index("eye", -1, 1))
	champion_1_design.go_Right_eye_index.connect(func(): _change_index("eye", 1, 1))
	champion_1_design.go_left_mouth_index.connect(func(): _change_index("mouth", -1, 1))
	champion_1_design.go_Right_mouth_index.connect(func(): _change_index("mouth", 1, 1))
	champion_1_design.set_color_skin.connect(func(): _change_color(1))

	# Connect signals for Champion 2
	champion_2_design.go_left_hair_index.connect(func(): _change_index("hair", -1, 2))
	champion_2_design.go_Right_hair_index.connect(func(): _change_index("hair", 1, 2))
	champion_2_design.go_left_eye_index.connect(func(): _change_index("eye", -1, 2))
	champion_2_design.go_Right_eye_index.connect(func(): _change_index("eye", 1, 2))
	champion_2_design.go_left_mouth_index.connect(func(): _change_index("mouth", -1, 2))
	champion_2_design.go_Right_mouth_index.connect(func(): _change_index("mouth", 1, 2))
	champion_2_design.set_color_skin.connect(func(): _change_color(2))

	# Update stat point labels
	stat_point_champion_1_txt.text = str(stats_point_champion1)
	stat_point_champion_2_txt.text = str(stats_point_champion2)

	# Clear existing stat children
	_clear_vbox(champion_1Vbox)
	_clear_vbox(champion_2Vbox)

	# Build stat changers dynamically
	var stats := STATS_COMPONENT.new()
	for stat_name in stats.base_stats.keys():
		var value = stats.base_stats[stat_name]

		var statChanger1 = STATS_CHANGER.instantiate()
		statChanger1.setup(stat_name, value)
		statChanger1.stat_added.connect(_on_stat_added_champion1)
		statChanger1.stat_removed.connect(_on_stat_removed_champion1)
		statChanger1.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger1.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		champion_1Vbox.add_child(statChanger1)

		var statChanger2 = STATS_CHANGER.instantiate()
		statChanger2.setup(stat_name, value)
		statChanger2.stat_added.connect(_on_stat_added_champion2)
		statChanger2.stat_removed.connect(_on_stat_removed_champion2)
		statChanger2.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger2.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		champion_2Vbox.add_child(statChanger2)

# --- Helpers ---

func _clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		child.queue_free()

func get_all_stats_from_VBoxContainer(vbox: VBoxContainer) -> Dictionary:
	var stats: Dictionary = {}
	for child: Stat_Changer in vbox.get_children():
		stats[child.stat_name_txt.text] = int(child.stat_amout_txt.text)
	return stats

# --- Stat buttons handlers ---
func _on_stat_added_champion1(stat_changer_class: Stat_Changer) -> void:
	if stats_point_champion1 < 1: return
	stats_point_champion1 -= 1
	stat_changer_class.amount += 1
	stat_changer_class._apply()
	stat_point_champion_1_txt.text = str(stats_point_champion1)

func _on_stat_removed_champion1(stat_changer_class: Stat_Changer) -> void:
	if stat_changer_class.amount <= min_stat_point: return
	stats_point_champion1 += 1
	stat_changer_class.amount -= 1
	stat_changer_class._apply()
	stat_point_champion_1_txt.text = str(stats_point_champion1)

func _on_stat_added_champion2(stat_changer_class: Stat_Changer) -> void:
	if stats_point_champion2 < 1: return
	stats_point_champion2 -= 1
	stat_changer_class.amount += 1
	stat_changer_class._apply()
	stat_point_champion_2_txt.text = str(stats_point_champion2)

func _on_stat_removed_champion2(stat_changer_class: Stat_Changer) -> void:
	if stat_changer_class.amount <= min_stat_point: return
	stats_point_champion2 += 1
	stat_changer_class.amount -= 1
	stat_changer_class._apply()
	stat_point_champion_2_txt.text = str(stats_point_champion2)

# --- Appearance handlers ---
func _change_index(feature: String, direction: int, champion: int) -> void:
	if champion == 1:
		match feature:
			"hair": hair_index_1 = wrapi(hair_index_1 + direction, 0, HairDataBase.hairs.size()); appearance_1.hair_id = hair_index_1
			"eye":  eye_index_1 = wrapi(eye_index_1 + direction, 0, EyeDataBase.eyes.size()); appearance_1.eye_id = eye_index_1
			"mouth": mouth_index_1 = wrapi(mouth_index_1 + direction, 0, MouthDataBase.mouths.size()); appearance_1.mouth_id = mouth_index_1
	else:
		match feature:
			"hair": hair_index_2 = wrapi(hair_index_2 + direction, 0, HairDataBase.hairs.size()); appearance_2.hair_id = hair_index_2
			"eye":  eye_index_2 = wrapi(eye_index_2 + direction, 0, EyeDataBase.eyes.size()); appearance_2.eye_id = eye_index_2
			"mouth": mouth_index_2 = wrapi(mouth_index_2 + direction, 0, MouthDataBase.mouths.size()); appearance_2.mouth_id = mouth_index_2
	
	champion_1_design.set_apperance(appearance_1)
	champion_2_design.set_apperance(appearance_2)

func _change_color(champion: int) -> void:
	if color_picker != null:
		color_picker.queue_free()
		color_picker = null
		return
	
	var initial_color := appearance_1.body_color if champion == 1 else appearance_2.body_color
	color_picker = ColorPicker.new()
	color_picker.color = initial_color
	color_picker.edit_alpha = false
	color_picker.edit_intensity = false
	color_picker.color_changed.connect(func(c: Color):
		if champion == 1:
			appearance_1.body_color = c
			champion_1_design.set_apperance(appearance_1)
		else:
			appearance_2.body_color = c
			champion_2_design.set_apperance(appearance_2)
	)
	add_child(color_picker)

# --- Save / Exit ---
func _on_save_btn_pressed() -> void:
	if stats_point_champion1 > 0 or stats_point_champion2 > 0:
		print("Must use all stat points")
		return
	
	var updated_data := {
		"champion1": get_all_stats_from_VBoxContainer(champion_1Vbox),
		"champion2": get_all_stats_from_VBoxContainer(champion_2Vbox)
	}
	var file := FileAccess.open(path, FileAccess.WRITE_READ)
	if file == null:
		print("Failed to open save file")
		return
	file.store_string(JSON.stringify(updated_data, "\t"))
	file.close()
	get_tree().change_scene_to_file("res://Scenes/gameScene/start meny/StartScene.tscn")

func _on_exit_btn_pressed() -> void:
	get_tree().quit()
